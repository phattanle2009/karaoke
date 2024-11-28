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
    
    @IBOutlet weak var pitchGraphView: PitchGraphView!
    @IBOutlet weak var karaokeTextContainer: UIStackView!
    @IBOutlet weak var pauseButton: UIButton!
    
    var song = UltraStarSong(lines: [])
    var audioPlayer: AVAudioPlayer?
    var currentLine = 0
    var drawDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let filePath = Bundle.main.path(forResource: "KjetilMrlandDebrahScarlett", ofType: "txt"),
           let lrcString = try? String(contentsOfFile: filePath, encoding: .utf8) {
            song = parseUltraStarFile(lrcString)
            loadAudio()
            startLyricsSync()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioPlayer?.pause()
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
                    let components = line.split(separator: "#TITLE:")
                    song.title = String(components[0]).replacingOccurrences(of: "\r", with: "")
                } else if (line.starts(with: "#ARTIST")) {
                    let components = line.split(separator: "#ARTIST:")
                    song.artist = String(components[0]).replacingOccurrences(of: "\r", with: "")
                } else if (line.starts(with: "#BPM")) {
                    var components = "\(line.split(separator: "#BPM:")[0])".replacingOccurrences(of: "\r", with: "")
                    components = components.replacingOccurrences(of: ",", with: ".")
                    song.BPM = (Double(components) ?? 0.0) * 4
                } else if (line.starts(with: "#GAP")) {
                    var components = "\(line.split(separator: "#GAP:")[0])".replacingOccurrences(of: "\r", with: "")
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
        pitchGraphView.pitchData = wordPitches
        pitchGraphView.setNeedsDisplay()
    }
    
    private func removePitchGraph() {
        pitchGraphView.pitchData = []
        pitchGraphView.setNeedsDisplay()
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
