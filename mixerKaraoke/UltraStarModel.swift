//
//  UltraStarModel.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 26/11/24.
//

struct UltraStarSong: Codable {
    
    var title: String = ""
    var artist: String = ""
    var BPM: Double = 0.0
    var GAP: Double = 0.0
    var tones: [Tone] = []
    var lines: [UltraStarLine]
    var fileName: String = ""
}

struct UltraStarLine: Codable {
    
    var from: Double = 0.0
    var to: Double = 0.0
    var syllables: [UltraStarWord]
}

struct UltraStarWord: Codable {
    
    var startTime: Double = 0.0
    var duration: Double = 0.0
    var pitch: Int = 0
    var word: String = ""
}
