//
//  DetailPitchesViewController.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 25/11/24.
//

import UIKit
import Foundation
import AVFoundation
import AudioKit

class KalmanFilter {
    private var estimate: Float = 0.0
    private var errorEstimate: Float = 1.0
    private let processNoise: Float = 1e-2
    private let measurementNoise: Float = 1e-1

    func update(measurement: Float) -> Float {
        let kalmanGain = errorEstimate / (errorEstimate + measurementNoise)
        estimate = estimate + kalmanGain * (measurement - estimate)
        errorEstimate = (1 - kalmanGain) * errorEstimate + abs(estimate) * processNoise
        return estimate
    }
}

class DetailPitchesViewController: UIViewController {
    
    @IBOutlet weak var nameOfSongLabel: UILabel!
    @IBOutlet weak var lyricsTableView: UITableView!
    @IBOutlet weak var pitchGraphScrollView: UIScrollView!
    @IBOutlet weak var pitchGraphView: UIStackView!
    @IBOutlet weak var blendColorView: UIView!
    @IBOutlet weak var pitchDetectorLabel: UILabel!
    @IBOutlet weak var bottomButtonWrapper: UIStackView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pitchArrow: UIImageView!
    // Constraint
    @IBOutlet weak var pitchArrow_TCT: NSLayoutConstraint!
    @IBOutlet weak var pitchGraphScrollView_HCT: NSLayoutConstraint!
    
    // song logic
    private var song = UltraStarSong(lines: [])
    private var currentLine = 0
    private var xOffset: CGFloat = 0
    private var stepScrollOffset: CGFloat = 0
    private var timer: DispatchSourceTimer?
    
    // audio input and output
    private var audioPlayer: AVAudioPlayer!
    private var mic: AudioEngine.InputNode!
    private var fftTap: FFTTap!
    private var engine: AudioEngine!
    private var updateCounter = 0
    private let kalmanFilter = KalmanFilter()
    private var frequencyBuffer: [Float] = []
    private let bufferSize = 10  // Số lượng giá trị tần số để làm mịn
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lyricsTableView.register(UINib(nibName: "LyricsTableViewCell", bundle: .main),
                                 forCellReuseIdentifier: "LyricsTableViewCell")
        lyricsTableView.delegate = self
        lyricsTableView.dataSource = self
        
        setupUI()
        
        if let filePath = Bundle.main.path(forResource: "KjetilMrlandDebrahScarlett", ofType: "txt"),
           let lrcString = try? String(contentsOfFile: filePath, encoding: .utf8) {
            song = UltraStarUtils.shared.parseUltraStarFile(lrcString)
            
            drawPitchGraph()
            
            // name
            nameOfSongLabel.text = song.title
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.loadAudio()
                self?.startLyricsSync()
            }
            setupAudioEngine()
            //startAudioEngine()
        }
        blendColorView.layer.compositingFilter = "hueBlendMode"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioPlayer.pause()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fftTap.stop()
        engine.stop()
    }
    
    private func setupUI() {
        // lyrics list and pitch graph
        [lyricsTableView, pitchGraphScrollView].forEach {
            $0?.layer.cornerRadius = 10.0
            $0?.layer.borderWidth = 2.0
            $0?.layer.borderColor = UIColor.lightGray.cgColor
        }
        let left = CGFloat((UIScreen.main.bounds.size.width - 24) / 3)
        pitchGraphScrollView.contentInset = UIEdgeInsets(top: 0.0, left: left, bottom: 0.0, right: 0.0)
        
        // pitch level
        pitchDetectorLabel.text = "Current Pitch: -- Hz"
        pitchDetectorLabel.textAlignment = .center
        pitchDetectorLabel.font = UIFont.systemFont(ofSize: 24)
        
        // bottom button wrapper
        bottomButtonWrapper.layer.cornerRadius = 10
    }
    
    private func loadAudio() {
        if let path = Bundle.main.path(forResource: "KjetilMrlandDebrahScarlett", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try! AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayer.volume = 1
            try! AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }
    }
    
    private func setupAudioEngine() {
        // Khởi tạo Audio Engine
        engine = AudioEngine()
        
        // Lấy microphone input
        guard let input = engine.input else { return }
        mic = input
        
        // Thêm FFT Tap để lấy dữ liệu FFT
        fftTap = FFTTap(mic) { fftData in
            DispatchQueue.main.async {
                self.analyzeFFTData(fftData)
            }
        }
        
        // Kích hoạt microphone input
        engine.output = Mixer(mic)
        
        fftTap.isNormalized = false
        fftTap.start()
        
        do {
            try engine.start()
        } catch {
            print("Audio Engine Error: \(error.localizedDescription)")
        }
    }
    
    private func analyzeFFTData(_ fftData: [Float]) {
        // Tìm giá trị lớn nhất trong FFT data (tần số trội)
        updateCounter += 1
        if updateCounter % 10 == 0 {
            restartEngineIfNeeded()
        } else {
            if let maxIndex = fftData.firstIndex(of: fftData.max() ?? 0) {
                let frequency = Float(maxIndex) * Float(engine.input!.outputFormat.sampleRate) / Float(fftData.count)
                let filteredFrequency = kalmanFilter.update(measurement: frequency)
                if frequency == 0 || frequency > Float(song.tones.first!.frequency) || frequency < Float(song.tones.last!.frequency) { return }
                let midiNote = Int(round(69 + 12 * log2(frequency / 440.0)))
                let tone = getToneName(by: midiNote)
                let matchToneIndex = CGFloat(song.tones.firstIndex(where: {$0.midi == tone.midi}) ?? 0)
                
                let smoothFrequency = smoothFrequency(newFrequency: filteredFrequency)
                print("=====> frequency: \(frequency)")
                print("=====> smoothFrequency: \(smoothFrequency)")
                print("=====> filteredFrequency: \(filteredFrequency)")
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1) {
                        self.pitchDetectorLabel.text = "Pitch: \(Int(frequency)) Hz - Tone: \(tone.pitch)"
                        self.pitchArrow.transform = CGAffineTransform(translationX: 0, y: matchToneIndex * 20.0)
                    }
                }
            }
        }
    }
    
    private func smoothFrequency(newFrequency: Float) -> Float {
        if frequencyBuffer.count >= bufferSize {
            frequencyBuffer.removeFirst()
        }
        frequencyBuffer.append(newFrequency)
        
        return frequencyBuffer.reduce(0, +) / Float(frequencyBuffer.count)
    }
    
    private func restartEngineIfNeeded() {
        if !engine.avEngine.isRunning {
            do {
                try engine.start()
            } catch {
                print("Error restarting Audio Engine: \(error)")
            }
        }
    }
    
    private func drawPitchGraph() {
        pitchGraphScrollView_HCT.constant = CGFloat(song.tones.count) * 20.0
        UltraStarUtils.shared.drawPitchGraph(with: song, to: pitchGraphView)
    }
    
    private func startLyricsSync() {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: 0.01)
        timer?.setEventHandler {
            if self.audioPlayer.isPlaying {
                let currentTime = self.audioPlayer.currentTime
                for (lineIdx, line) in self.song.lines.enumerated() {
                    if lineIdx + 1 < self.song.lines.count {
                        let nextTime = self.song.lines[lineIdx + 1].syllables.first!.startTime
                        if currentTime >= line.syllables.first!.startTime && currentTime < nextTime {
                            self.currentLine = lineIdx
                            self.scrollToCurrentLine()
                            break
                        }
                    } else if currentTime >= line.syllables.first!.startTime {
                        self.currentLine = lineIdx
                        self.scrollToCurrentLine()
                    }
                }
                let scale = UIScreen.main.scale
                
                if self.stepScrollOffset == 0 {
                    self.stepScrollOffset = self.pitchGraphScrollView.contentSize.width / 19700 // cứ mỗi 0.01 giây nó cần scroll thêm chừng này offset
                    self.stepScrollOffset = round(self.stepScrollOffset * scale) / scale
                }
                let leftInset = self.pitchGraphScrollView.frame.width / 3
                let offsetX = (round(currentTime * 100 * self.stepScrollOffset * scale) / scale) - leftInset
                self.scrollPitchGraph(to: offsetX)
            }
        }
        timer?.resume()
    }
    
    private func scrollPitchGraph(to offset: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.pitchGraphScrollView.contentOffset.x = offset
            }
        }
    }
    
    @IBAction func tapOnPrevButton(_ sender: Any) {
        audioPlayer.stop()
        xOffset = xOffset - stepScrollOffset * 1000
        xOffset = xOffset <= 0 ? 0 : xOffset
        audioPlayer.currentTime = audioPlayer.currentTime - 10
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    @IBAction func tapOnPauseButton(_ sender: Any) {
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                self.audioPlayer.pause()
                pauseButton.setImage(UIImage(systemName: "play.circle"),
                                     for: .normal)
            } else {
                self.audioPlayer.play()
                pauseButton.setImage(UIImage(systemName: "pause.circle"),
                                     for: .normal)
            }
        }
    }
    
    @IBAction func tapOnNextButton(_ sender: Any) {
        audioPlayer.stop()
        xOffset = xOffset + stepScrollOffset * 1000
        xOffset = xOffset >= pitchGraphScrollView.contentSize.width ? pitchGraphScrollView.contentSize.width : xOffset
        audioPlayer.currentTime = audioPlayer.currentTime + 10
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
}

// MARK: - Table view
extension DetailPitchesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollToCurrentLine() {
        let indexPath = IndexPath(row: currentLine, section: 0)
        lyricsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        lyricsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return song.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LyricsTableViewCell",
                                                       for: indexPath) as? LyricsTableViewCell
        else { return .init() }
        let data = song.lines[indexPath.row]
        let isHighlight = indexPath.row == currentLine
        guard let player = audioPlayer else { return .init() }
        let currentTime = player.currentTime
        cell.configCell(data: data.syllables, isHighlight: isHighlight, currentTime: currentTime)
        return cell
    }
}
