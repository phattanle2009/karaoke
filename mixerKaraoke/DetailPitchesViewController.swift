//
//  DetailPitchesViewController.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 25/11/24.
//

import UIKit
import Foundation
import AVFoundation

class DetailPitchesViewController: UIViewController {
    
    @IBOutlet weak var nameOfSongLabel: UILabel!
    @IBOutlet weak var lyricsTableView: UITableView!
    @IBOutlet weak var pitchGraphView: UIStackView!
    @IBOutlet weak var pitchDetectorLabel: UILabel!
    @IBOutlet weak var bottomButtonWrapper: UIStackView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var song = UltraStarSong(lines: [])
    var audioPlayer: AVAudioPlayer!
    var currentLine = 0
    var pitchDetector = PitchDetector()
    
    //
    private let audioEngine = AVAudioEngine()
    private var inputNode: AVAudioInputNode?
    private let bus: AVAudioNodeBus = 0
    private let bufferSize: AVAudioFrameCount = 1024
    private let amplitudeThreshold: Float = 0.08  // Ngưỡng biên độ
    private let minPitch: Float = 80.0            // Ngưỡng pitch thấp nhất
    private let maxPitch: Float = 1000.0          // Ngưỡng pitch cao nhất
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lyricsTableView.register(UINib(nibName: "LyricsTableViewCell", bundle: .main),
                                 forCellReuseIdentifier: "LyricsTableViewCell")
        lyricsTableView.delegate = self
        lyricsTableView.dataSource = self
        
        if let filePath = Bundle.main.path(forResource: "KjetilMrlandDebrahScarlett", ofType: "txt"),
           let lrcString = try? String(contentsOfFile: filePath, encoding: .utf8) {
            song = UltraStarUtils.shared.parseUltraStarFile(lrcString)
            loadAudio()
            startLyricsSync()
            setupUI()
            startAudioEngine()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioPlayer.pause()
        audioEngine.stop()
        inputNode!.removeTap(onBus: bus)
    }
    
    private func setupUI() {
        // name
        nameOfSongLabel.text = song.title
        
        // pitch chart
        pitchGraphView.layer.cornerRadius = 10
        
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
            audioPlayer.play()
        }
    }
    
    private func startLyricsSync() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let currentTime = self.audioPlayer.currentTime
            for (lineIdx, line) in self.song.lines.enumerated() {
                for (syllablesIdx, syllables) in line.syllables.enumerated() {
                    if lineIdx == self.currentLine {
                        // cập nhật lại line mới, remove cái line cũ đi
                        if currentTime > line.syllables.last!.startTime {
                            self.removePitchGraph()
                            break
                        }
                        
                        // tô màu cho cái chữ đang hát
                        if currentTime >= syllables.startTime {
                            self.pitchGraphView.arrangedSubviews.forEach { subview in
                                if subview.tag == syllablesIdx {
                                    subview.subviews.first?.backgroundColor = .systemBlue
                                }
                            }
                        }
                        
                        if self.pitchGraphView.arrangedSubviews.isEmpty {
                            UltraStarUtils.shared.drawPitchGraph(with: line.syllables, to: self.pitchGraphView)
                        }
                        
                        self.lyricsTableView.reloadData()
                    }
                }
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
        }
    }
    
    private func removePitchGraph() {
        pitchGraphView.arrangedSubviews.forEach { subview in
            pitchGraphView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func tapOnPrevButton(_ sender: Any) {
        audioPlayer.stop()
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
        audioPlayer.currentTime = audioPlayer.currentTime + 10
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
}

// MARK: - Table view
extension DetailPitchesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollToCurrentLine() {
        let indexPath = IndexPath(row: currentLine, section: 0)
        lyricsTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
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
        let pitch = self.calculateFrequency(from: channelDataArray)
        
        // kiểm tra nếu pitch nằm trong ngưỡng hợp lệ
        if pitch >= minPitch && pitch <= maxPitch {
            DispatchQueue.main.async {
                self.pitchDetectorLabel.text = "Current Pitch: \(String(format: "%.2f", pitch)) Hz"
                print(pitch)
            }
        }
    }
    
    // tính toán tần số từ dữ liệu (Placeholder - thay bằng thuật toán FFT/autocorrelation thực tế)
    private func calculateFrequency(from samples: [Float]) -> Float {
        // placeholder: logic phát hiện pitch thực tế cần thêm ở đây
        return Float.random(in: 80...1000)  // tạm thời trả về giá trị ngẫu nhiên
    }
}
