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
            song = parseUltraStarFile(lrcString)
            loadAudio()
            startLyricsSync()
            setupUI()
            startAudioEngine()
        }
    }
    
    private func setupUI() {
        pitchDetectorLabel.text = "Current Pitch: -- Hz"
        pitchDetectorLabel.textAlignment = .center
        pitchDetectorLabel.font = UIFont.systemFont(ofSize: 24)
    }
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioPlayer?.pause()
        audioEngine.stop()
        inputNode!.removeTap(onBus: bus)
    }
    
    func loadAudio() {
        if let path = Bundle.main.path(forResource: "KjetilMrlandDebrahScarlett", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
    }
    
    func startLyricsSync() {
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
                            self.drawPitchGraph(wordPitches: line.syllables)
                        }
                    }
                }
            }
        }
    }
    
    func beatToSeconds(beat: Double, bpm: Double) -> Double {
        return (beat / bpm) * 60
    }
    
    func parseUltraStarFile(_ content: String) -> UltraStarSong {
        let lines = content.components(separatedBy: "\n")
        var song = UltraStarSong(lines: [])
        var lastLine = UltraStarLine(syllables: [])
        
        for line in lines {
            if(line.starts(with: "#")) {
                if (line.starts(with: "#TITLE")) {
                    let components = line.components(separatedBy: "#TITLE:")
                    song.title = String(components[1]).replacingOccurrences(of: "\r", with: "")
                } else if (line.starts(with: "#ARTIST")) {
                    let components = line.components(separatedBy: "#ARTIST:")
                    song.artist = String(components[1]).replacingOccurrences(of: "\r", with: "")
                } else if (line.starts(with: "#BPM")) {
                    var components = "\(line.components(separatedBy: "#BPM:")[1])".replacingOccurrences(of: "\r", with: "")
                    components = components.replacingOccurrences(of: ",", with: ".")
                    song.BPM = (Double(components) ?? 0.0) * 4
                } else if (line.starts(with: "#GAP")) {
                    var components = "\(line.components(separatedBy: "#GAP:")[1])".replacingOccurrences(of: "\r", with: "")
                    components = components.replacingOccurrences(of: ",", with: ".")
                    song.GAP = (Double(components) ?? 0.0) / 1000.0
                }
            }
            else {
                if (line.starts(with: ":") || line.starts(with: "*") || line.starts(with: "F")) {
                    let components = getLineComponents(data: line)
                    if components.count >= 5 {
                        let startTime = Double(components[1]) ?? 0.0
                        let duration = Double(components[2]) ?? 0.0
                        let pitch = Int(components[3]) ?? 0
                        let word = "\(components[4...].joined(separator: " "))".replacingOccurrences(of: "\r", with: "")
                        let startInSeconds = beatToSeconds(beat: startTime, bpm: song.BPM) + song.GAP
                        let lyricWord = UltraStarWord(startTime: startInSeconds,
                                                      duration: duration,
                                                      pitch: pitch,
                                                      word: word)
                        lastLine.syllables.append(lyricWord)
                    }
                } else if (line.starts(with: "-")) {
                    let components = "\(line.split(separator: "-")[0])".replacingOccurrences(of: "\r", with: "")
                    lastLine.from = Double(components) ?? 0.0
                    song.lines.append(lastLine)
                    let a = lastLine.syllables.map { $0.word }.joined()
                    print(a)
                    lastLine.syllables.removeAll()
                }
            }
        }
        return song
    }
    
    func getLineComponents(data: String) -> [String] {
        var result: [String] = []
        var tmp = ""
        let spaceCount = data.filter{$0 == " "}.count
        let component = data.split(separator: " ")
        if component.count >= 5 {
            for idx in 0..<component.count  {
                if idx == component.count - 1 && spaceCount > 4 {
                    tmp = " \(component[idx])"
                } else {
                    tmp = "\(component[idx])"
                }
                result.append(tmp)
            }
        }
        return result
    }
    
    func drawPitchGraph(wordPitches: [UltraStarWord]) {
        let barHeight: CGFloat = 28
        let barWidth: CGFloat = 10
        
        for (index, pitch) in wordPitches.enumerated() {
            let width = barWidth * pitch.duration
            let pitchY = CGFloat(pitch.pitch * 6) + 50 // 50 is padding
            
            let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 160.0))
            container.translatesAutoresizingMaskIntoConstraints = false
            container.tag = index
            pitchGraphView.addArrangedSubview(container)
            
            let pitchView = UIView()
            pitchView.translatesAutoresizingMaskIntoConstraints = false
            pitchView.layer.cornerRadius = 5
            pitchView.backgroundColor = .systemYellow
            
            container.addSubview(pitchView)
            
            NSLayoutConstraint.activate([
                pitchView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
                pitchView.topAnchor.constraint(equalTo: container.topAnchor, constant: pitchY),
                pitchView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
                pitchView.heightAnchor.constraint(equalToConstant: barHeight),
            ])
            
            let label = UILabel()
            label.text = pitch.word
            label.lineBreakMode = .byCharWrapping
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 14.0)
            label.textColor = .white
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            
            pitchView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: pitchView.leadingAnchor, constant: 0),
                label.topAnchor.constraint(equalTo: pitchView.topAnchor, constant: 0),
                label.trailingAnchor.constraint(equalTo: pitchView.trailingAnchor, constant: 0),
                label.bottomAnchor.constraint(equalTo: pitchView.bottomAnchor, constant: 0),
                label.widthAnchor.constraint(equalToConstant: width),
            ])
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
