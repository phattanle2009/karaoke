//
//  AudioManager.swift
//  mixerKaraoke
//
//  Created by tanphat.le on 25/12/24.
//

import AVFoundation

protocol AudioManagerDelegate {
    func didUpdateFrequency(frequency: Float, tone: Tone, index: CGFloat)
}

class AudioManager: NSObject {
    
    var tones: [Tone] = []
    var delegate: AudioManagerDelegate?
    var audioPlayer: AVAudioPlayer!
    var audioSession: AVAudioSession!
    var soundRecorder: AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    private var updateCounter = 0
    
    override init() {
        super.init()
        setUpAudioSession()
        setupRecorder()
    }
    
    func loadAudio(with fileName: String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            audioPlayer = try! AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayer.volume = 1
        }
    }
    
    func setUpAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord,
                                         mode: .default,
                                         options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func setupRecorder() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless,
                   AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                        AVEncoderBitRateKey : 320000,
                      AVNumberOfChannelsKey : 2,
                            AVSampleRateKey : 44100.2] as [String : Any]
        
        do {
            soundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting )
            soundRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    func setupPlayer() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    private func stopRecording() {
        if soundRecorder != nil {
            soundRecorder.stop()
            soundRecorder = nil
            setupPlayer()
        }
    }
    
    func playRecording() {
        soundPlayer.play()
    }
    
    func start() {
        audioPlayer.play()
        soundRecorder.record()
    }
    
    func stop() {
        audioPlayer.stop()
        stopRecording()
        if soundPlayer.isPlaying {
            soundPlayer.stop()
        }
    }
    
    func pause() {
        audioPlayer.pause()
        soundRecorder.pause()
    }
    
    func resume() {
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        soundRecorder.prepareToRecord()
        soundRecorder.record()
    }
    
    func seek(isNext: Bool = true, seconds: TimeInterval = 10) {
        audioPlayer.pause()
        let seekTime = max(audioPlayer.currentTime - (isNext ? -seconds : seconds), 0)
        audioPlayer.currentTime = seekTime
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
