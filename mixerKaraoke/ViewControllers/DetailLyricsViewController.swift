//
//  HomeViewController.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 25/11/24.
//

import UIKit
import AVFoundation

struct LyricLine {
    let time: TimeInterval
    let text: String
}

class DetailLyricsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var lyrics: [LyricLine] = []
    var audioPlayer: AVAudioPlayer?
    var currentLine: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadLyrics()
        playSong()
        syncLyrics()
    }
    
    func parseLRC(from lrcString: String) -> [LyricLine] {
        var lyrics: [LyricLine] = []
        let lines = lrcString.components(separatedBy: "\n")
        
        let timePattern = "\\[(\\d{2}):(\\d{2}\\.\\d{2})\\]"
        let timeRegex = try! NSRegularExpression(pattern: timePattern)
        
        for line in lines {
            if let match = timeRegex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                let minRange = Range(match.range(at: 1), in: line)!
                let secRange = Range(match.range(at: 2), in: line)!
                
                let minutes = Double(line[minRange]) ?? 0
                let seconds = Double(line[secRange]) ?? 0
                
                let time = minutes * 60 + seconds
                
                let lyricText = line.replacingOccurrences(of: timePattern,
                                                          with: "",
                                                          options: .regularExpression).trimmingCharacters(in: .whitespaces)
                lyrics.append(LyricLine(time: time, text: lyricText))
            }
        }
        return lyrics
    }

    
    func loadLyrics() {
        if let path = Bundle.main.path(forResource: "sample", ofType: "lrc") {
            if let lrcString = try? String(contentsOfFile: path, encoding: .utf8) {
                lyrics = parseLRC(from: lrcString)
                tableView.reloadData()
            }
        }
    }
    
    func playSong() {
        if let path = Bundle.main.path(forResource: "sample", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }
    }
    
    func syncLyrics() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let strongSelf = self,
                  let player = strongSelf.audioPlayer else { return }
            let currentTime = player.currentTime
            
            for (index, line) in strongSelf.lyrics.enumerated() {
                if index + 1 < strongSelf.lyrics.count {
                    let nextTime = strongSelf.lyrics[index + 1].time
                    if currentTime >= line.time && currentTime < nextTime {
                        strongSelf.currentLine = index
                        strongSelf.scrollToCurrentLine()
                        break
                    }
                } else if currentTime >= line.time {
                    strongSelf.currentLine = index
                    strongSelf.scrollToCurrentLine()
                }
            }
        }
    }
    
    func scrollToCurrentLine() {
        let indexPath = IndexPath(row: currentLine, section: 0)
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        tableView.reloadData()
    }
}

extension DetailLyricsViewController: UITableViewDataSource, UITableViewDelegate {
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lyrics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LyricCell", for: indexPath)
        let lyricLine = lyrics[indexPath.row]
        
        cell.textLabel?.text = lyricLine.text
        cell.textLabel?.textAlignment = .center
        
        if indexPath.row == currentLine {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            cell.textLabel?.textColor = .blue
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = .gray
        }
        
        return cell
    }
}
