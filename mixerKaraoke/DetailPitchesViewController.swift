//
//  DetailPitchesViewController.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 25/11/24.
//

import UIKit
import Foundation
import AVFoundation
import Accelerate

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
    // Constraint
    @IBOutlet weak var pitchArrow_TCT: NSLayoutConstraint!
    @IBOutlet weak var pitchGraphScrollView_HCT: NSLayoutConstraint!
    
    private var song = UltraStarSong(lines: [])
    private var audioPlayer: AVAudioPlayer!
    private var currentLine = 0
    private var pitchDetector = PitchDetector()
    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private let player = AVAudioPlayerNode()
    private let bus: AVAudioNodeBus = 0
    private let bufferSize: AVAudioFrameCount = 1024
    private let amplitudeThreshold: Float = 0.08   // Ngưỡng biên độ
    private let minPitch: Float = 16.0             // Ngưỡng pitch thấp nhất
    private let maxPitch: Float = 13289.0          // Ngưỡng pitch cao nhất
    private var xOffset: CGFloat = 0
    private var stepScrollOffset: CGFloat = 0
    private var timer: DispatchSourceTimer?
    
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
            startAudioEngine()
        }
        blendColorView.layer.compositingFilter = "hueBlendMode"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioPlayer.pause()
        audioEngine.stop()
        inputNode!.removeTap(onBus: bus)
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

// MARK: - Pitch Detector
extension DetailPitchesViewController {
    
    private func startAudioEngine() {
        inputNode = audioEngine.inputNode
        let format = inputNode!.outputFormat(forBus: bus)
        
        inputNode!.installTap(onBus: bus, bufferSize: bufferSize, format: format) { (buffer, _) in
            self.detectPitch(from: buffer)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    // detect pitch với threshold
    private func detectPitch(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        
        // biên độ trung bình
        let amplitude = channelDataArray.map { abs($0) }.reduce(0, +) / Float(buffer.frameLength)
        
        // bỏ qua biên độ dưới ngưỡng
        if amplitude < amplitudeThreshold {
            return
        }
        
        // detect pitch từ tín hiệu (giả lập đơn giản)
        let pitch = self.calculateFrequency(from: buffer)
        let tone = getToneName(by: Double(pitch))
        let matchToneIndex = CGFloat(song.tones.firstIndex(where: {$0.midi == tone.midi}) ?? 0)
        
        // kiểm tra nếu pitch nằm trong ngưỡng hợp lệ
        if pitch >= minPitch && pitch <= maxPitch {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    self.pitchDetectorLabel.text = "Pitch: \(pitch) Hz - Tone: \(tone.pitch)"
                    print("====> Pitch: \(pitch) Hz\n====> Tone: \(tone.pitch)")
                    self.pitchArrow_TCT.constant = matchToneIndex * 20.0
                }
            }
        }
    }
    
    // tính toán tần số từ dữ liệu bằng thuật toán FFT/autocorrelation thực tế
    func calculateFrequency(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else {
            return 0.0
        }
        
        let frameCount = Int(buffer.frameLength)
        let log2n = vDSP_Length(log2(Float(frameCount)))
        
        // Cấp phát bộ nhớ cho realp và imagp
        let realp = UnsafeMutableBufferPointer<Float>.allocate(capacity: frameCount / 2)
        let imagp = UnsafeMutableBufferPointer<Float>.allocate(capacity: frameCount / 2)
        defer {
            realp.deallocate()
            imagp.deallocate()
        }
        
        // Tạo FFT setup
        guard let fftSetup = vDSP_create_fftsetup(log2n, Int32(kFFTRadix2)) else {
            return 0.0
        }
        defer {
            vDSP_destroy_fftsetup(fftSetup)
        }
        
        // Đưa dữ liệu vào FFT
        var output = DSPSplitComplex(realp: realp.baseAddress!, imagp: imagp.baseAddress!)
        channelData.withMemoryRebound(to: DSPComplex.self, capacity: frameCount) { pointer in
            vDSP_ctoz(pointer, 2, &output, 1, vDSP_Length(frameCount / 2))
        }
        
        vDSP_fft_zrip(fftSetup, &output, 1, log2n, FFTDirection(FFT_FORWARD))
        
        // Tính biên độ
        var magnitudes = [Float](repeating: 0.0, count: frameCount / 2)
        vDSP_zvmags(&output, 1, &magnitudes, 1, vDSP_Length(frameCount / 2))
        
        // Tìm tần số có biên độ lớn nhất
        var maxMagnitude: Float = 0
        var maxIndex: vDSP_Length = 0
        vDSP_maxvi(&magnitudes, 1, &maxMagnitude, &maxIndex, vDSP_Length(frameCount / 2))
        
        // Tính tần số tương ứng
        let sampleRate = buffer.format.sampleRate
        let frequency = Float(maxIndex) * Float(sampleRate) / Float(frameCount)
        
        return frequency
    }
}
