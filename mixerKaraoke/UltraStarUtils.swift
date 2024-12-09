//
//  UltraStarUtils.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 2/12/24.
//

import UIKit

class UltraStarUtils {
    
    static let shared = UltraStarUtils()
    
    func parseUltraStarFile(_ content: String) -> UltraStarSong {
        let lines = content.components(separatedBy: "\n")
        var song = UltraStarSong(lines: [])
        var lastLine = UltraStarLine(syllables: [])
        var lastTo: Double = 0.0
        
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
            } else {
                if (line.starts(with: ":") || line.starts(with: "*") || line.starts(with: "F")) {
                    let components = getLineComponents(data: line)
                    if components.count >= 5 {
                        let startTime = Double(components[1]) ?? 0.0
                        let duration = Double(components[2]) ?? 0.0
                        let pitch = Int(components[3]) ?? 0
                        let word = "\(components[4...].joined(separator: " "))".replacingOccurrences(of: "\r", with: "")
                        let startInSeconds = beatToSeconds(beat: startTime, bpm: song.BPM, gap: song.GAP)
                        let durationInSeconds = beatToSeconds(beat: duration, bpm: song.BPM, gap: 0)
                        let lyricWord = UltraStarWord(startTime: startInSeconds,
                                                      duration: durationInSeconds,
                                                      pitch: pitch,
                                                      word: word)
                        if song.lines.isEmpty {
                            lastLine.from = 0
                        } else {
                            if lastLine.syllables.isEmpty {
                                lastLine.from = lastTo
                            }
                        }
                        lastLine.syllables.append(lyricWord)
                    }
                } else if line.starts(with: "-") { // kết thúc 1 phrase
                    var blankWord = UltraStarWord()
                    if song.lines.isEmpty { // cái này là chưa có mẹ gì, add cho nó cái đoạn đầu nhạc
                        blankWord.duration = song.GAP
                    } else {
                        let delay: Double = lastLine.syllables.first!.startTime - lastTo
                        blankWord.startTime = lastTo
                        blankWord.duration = delay
                    }
                    lastLine.syllables.insert(blankWord, at: 0)
                    let lastWord = lastLine.syllables.last
                    lastLine.to = lastWord!.startTime + lastWord!.duration
                    lastTo = lastLine.to
                    song.lines.append(lastLine)
                    lastLine.syllables.removeAll()
                } else if line.starts(with: "E") { // kết thúc bài hát
                    let lastWord = lastLine.syllables.last
                    lastLine.to = lastWord!.startTime + lastWord!.duration
                    song.lines.append(lastLine)
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
    
    func beatToSeconds(beat: Double, bpm: Double, gap: Double) -> Double {
        return gap + (beat / bpm) * 60
    }
    
    func drawPitchGraph(with pitches: [UltraStarWord], to view: UIStackView) {
        let barHeight: CGFloat = 20
        let barWidth: CGFloat = 200.0
        
        for (index, pitch) in pitches.enumerated() {
            let width = barWidth * pitch.duration
            let pitchY = CGFloat(pitch.pitch * 6) + 50 // 50 is padding
            
            let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 160.0))
            container.translatesAutoresizingMaskIntoConstraints = false
            container.tag = index
            view.addArrangedSubview(container)
            
            let pitchView = UIView()
            pitchView.translatesAutoresizingMaskIntoConstraints = false
            pitchView.layer.cornerRadius = 5
            pitchView.backgroundColor = pitch.word.isEmpty ? .clear : .systemYellow
            
            container.addSubview(pitchView)
            
            NSLayoutConstraint.activate([
                pitchView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
                pitchView.topAnchor.constraint(equalTo: container.topAnchor, constant: pitchY),
                pitchView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
                pitchView.heightAnchor.constraint(equalToConstant: barHeight),
                pitchView.widthAnchor.constraint(equalToConstant: width),
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
}
