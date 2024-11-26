//
//  DetailPitchesViewController.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 25/11/24.
//

import UIKit
import Foundation
import AVFoundation

struct UltraStarWord: Codable {
    let startTime: Double
    let duration: Double
    let pitch: Int
    let word: String
}

class DetailPitchesViewController: UIViewController {
    
    @IBOutlet weak var lyricsLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    var lyricsData: [UltraStarWord] = []
    var audioPlayer: AVAudioPlayer?
    var currentWordIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let filePath = Bundle.main.path(forResource: "KjetilMrlandDebrahScarlett", ofType: "txt"),
            let lrcString = try? String(contentsOfFile: filePath, encoding: .utf8) {
            lyricsData = parseUltraStarFile(lrcString, bpm: 303.48, gap: 5823.23 / 1000)
            loadAudio()
            startLyricsSync()
            // drawPitchGraph(wordPitches: lyricsData)
        }
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
            
            if self.currentWordIndex < self.lyricsData.count {
                let word = self.lyricsData[self.currentWordIndex]
                if currentTime >= word.startTime {
                    self.lyricsLabel.text = word.word
                    self.currentWordIndex += 1
                }
            }
        }
    }
    
    
    func beatToSeconds(beat: Double, bpm: Double) -> Double {
        return (beat / (bpm * 4)) * 60
    }
    
    func parseUltraStarFile(_ content: String, bpm: Double, gap: Double) -> [UltraStarWord] {
        var lyricsData: [UltraStarWord] = []
        let lines = content.components(separatedBy: "\n")
        
        for line in lines {
            if line.starts(with: ":") {
                let components = line.split(separator: " ")
                if components.count >= 5 {
                    let startTime = Double(components[1]) ?? 0.0
                    let duration = Double(components[2]) ?? 0.0
                    let pitch = Int(components[3]) ?? 0
                    let word = components[4...].joined(separator: " ")
                    let startInSeconds = beatToSeconds(beat: startTime, bpm: bpm) + gap
                    let lyricLine = UltraStarWord(startTime: startInSeconds,
                                                  duration: duration,
                                                  pitch: pitch,
                                                  word: word)
                    lyricsData.append(lyricLine)
                }
            }
        }
        return lyricsData
    }
    
    /*
     public static Song parse(List<String> data) throws Exception {
             Song song = new Song();
             Song.Line lastLine = null;
             for (String line : data) {
                 // tags
     if(line.starts(with: "#")) {
         if (line.starts(with: "#TITLE")) {
             song.title = getStringValue(line, "#TITLE");
         } else if (line.starts(with: "#ARTIST")) {
             song.artist = getStringValue(line, "#ARTIST");
         } else if (line.starts(with: "#EDITION")) {
             //
         } else if (line.starts(with: "#LANGUAGE")) {
             //
         } else if (line.starts(with: "#GENRE")) {
             //
         } else if (line.starts(with: "#MP3")) {
             song.file = getStringValue(line, "#MP3");
         } else if (line.starts(with: "#COVER")) {
            song.cover = getStringValue(line, "#COVER");
         } else if (line.starts(with: "#BPM")) {
             song.BPM = getFloatValue(line, "#BPM") * 4;
         } else if (line.starts(with: "#GAP")) {
             song.gap = getFloatValue(line, "#GAP") / 1000.0;
         }
     }
     else {
         // lyrics
         if (line.starts(with: ":") || line.starts(with: "*") || line.starts(with: "F")) {
             Song.Syllable syllable = parseSyllable(song, line);
             if(null == lastLine) {
                 lastLine = new Song.Line();
                 song.lines.add(lastLine);
             }
             lastLine.syllables.add(syllable);
         } else if (line.starts(with: "-")) {
             int[] timestamps = parseInts(line);
             if(timestamps.length < 1)
                 throw new Exception("Bad line delimiter: " + line);
             if(null == lastLine)
                 continue;
             lastLine.to = getTimestamp(song, timestamps[0]);
             lastLine = new Song.Line();
             song.lines.add(lastLine);
             if(timestamps.length > 1)
                 lastLine.from = getTimestamp(song, timestamps[1]);
         }
     }
             }

             // fix starts
             for(Song.Line line : song.lines)
                 if(line.from == 0 && line.syllables.size() > 0)
                     line.from = line.syllables.get(0).from;

             return song;
         }
     */
    
    func drawPitchGraph(wordPitches: [UltraStarWord]) {
        for (index, word) in wordPitches.enumerated() {
            let pitchBar = UIView(frame: CGRect(x: CGFloat(index) * 30,
                                                y: CGFloat(100 - word.pitch * 5),
                                                width: 20,
                                                height: 20))
            pitchBar.backgroundColor = .blue
            self.view.addSubview(pitchBar)
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
