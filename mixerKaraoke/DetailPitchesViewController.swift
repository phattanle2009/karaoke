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
    
    @IBOutlet weak var pitchDetectorLabel: UILabel!
    @IBOutlet weak var pitchGraphView: UIStackView!
    @IBOutlet weak var karaokeTextContainer: UIStackView!
    @IBOutlet weak var pauseButton: UIButton!
    
    var song = UltraStarSong(lines: [])
    var audioPlayer: AVAudioPlayer?
    var currentLine = 0
    var drawDone = false
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
        audioPlayer?.pause()
        audioEngine.stop()
        inputNode!.removeTap(onBus: bus)
    }
    
    private func setupUI() {
        pitchDetectorLabel.text = "Current Pitch: -- Hz"
        pitchDetectorLabel.textAlignment = .center
        pitchDetectorLabel.font = UIFont.systemFont(ofSize: 24)
    }
    
    private func loadAudio() {
        if let path = Bundle.main.path(forResource: "KjetilMrlandDebrahScarlett", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
    }
    
    private func startLyricsSync() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard let player = self.audioPlayer else { return }
            let currentTime = player.currentTime
            for (lineIdx, line) in self.song.lines.enumerated() {
                for (syllablesIdx, syllables) in line.syllables.enumerated() {
                    if lineIdx == self.currentLine {
                        // cập nhật lại line mới, remove cái line cũ đi
                        if currentTime > line.syllables.last!.startTime {
                            self.currentLine += 1
                            self.drawDone = false
                            self.karaokeTextContainer.arrangedSubviews.forEach { subview in
                                self.karaokeTextContainer.removeArrangedSubview(subview)
                                subview.removeFromSuperview()
                            }
                            self.removePitchGraph()
                            break
                        }
                        
                        // tô màu cho cái chữ đang hát
                        if currentTime >= syllables.startTime {
                            self.karaokeTextContainer.arrangedSubviews.forEach { subview in
                                if let label = subview as? UILabel, subview.tag == syllablesIdx {
                                    label.textColor = .systemBlue
                                }
                            }
                            self.pitchGraphView.arrangedSubviews.forEach { subview in
                                if subview.tag == syllablesIdx {
                                    subview.subviews.first?.backgroundColor = .systemBlue
                                }
                            }
                        }
                        
                        // kh done thì cứ thế mà vẽ chữ
                        if !self.drawDone {
                            let label = UILabel()
                            label.tag = syllablesIdx
                            label.textColor = .black
                            label.text = syllables.word
                            label.font = .boldSystemFont(ofSize: 32.0)
                            label.translatesAutoresizingMaskIntoConstraints = false
                            self.karaokeTextContainer.addArrangedSubview(label)
                        }
                        
                        // vẽ xong thì kh cho nó vẽ nữa, kh cho vào stack nữa
                        if syllablesIdx == line.syllables.count - 1 {
                            self.drawDone = true
                        }
                        
                        if self.pitchGraphView.arrangedSubviews.isEmpty {
                            UltraStarUtils.shared.drawPitchGraph(with: line.syllables, to: self.pitchGraphView)
                        }
                    }
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
    
    @IBAction func tapOnPauseButton(_ sender: Any) {
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                self.audioPlayer!.pause()
                pauseButton.setTitle("Resume", for: .normal)
            } else {
                self.audioPlayer!.play()
                pauseButton.setTitle("Pause", for: .normal)
            }
        }
    }
}

// MARK: - Pitch Detector
extension DetailPitchesViewController {
    
    // Bắt đầu AVAudioEngine
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
    
    // Phát hiện pitch với threshold
    private func detectPitch(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        
        // Tính toán biên độ trung bình
        let amplitude = channelDataArray.map { abs($0) }.reduce(0, +) / Float(buffer.frameLength)
        
        // Bỏ qua nếu biên độ dưới ngưỡng
        if amplitude < amplitudeThreshold {
            return
        }
        
        // Phát hiện pitch từ tín hiệu (giả lập đơn giản)
        let pitch = self.calculateFrequency(from: channelDataArray)
        
        // Kiểm tra nếu pitch nằm trong ngưỡng hợp lệ
        if pitch >= minPitch && pitch <= maxPitch {
            DispatchQueue.main.async {
                self.pitchDetectorLabel.text = "Current Pitch: \(String(format: "%.2f", pitch)) Hz"
                print(pitch)
            }
        }
    }
    
    // Hàm tính toán tần số từ dữ liệu (Placeholder - thay bằng thuật toán FFT/autocorrelation thực tế)
    
    private func calculateFrequency(from samples: [Float]) -> Float {
        // Placeholder: Logic phát hiện pitch thực tế cần thêm ở đây
        return Float.random(in: 80...1000)  // Tạm thời trả về giá trị ngẫu nhiên
    }
}
