//
//  AudioManager.swift
//  mixerKaraoke
//
//  Created by tanphat.le on 25/12/24.
//

import AVFoundation
import AudioKit
import AudioKitEX

protocol AudioManagerDelegate {
    func didUpdateFrequency(frequency: Float, tone: Tone, index: CGFloat)
}

class AudioManager {
    
    var fftTap: FFTTap!
    var tones: [Tone] = []
    var audioEngine: AudioEngine!
    var recordPlayer: AudioPlayer!
    var nodeRecorder: NodeRecorder!
    var audioPlayer = AudioPlayer()
    var delegate: AudioManagerDelegate?
    private var updateCounter = 0
    private var mic: AudioEngine.InputNode!
    
    init() {
        setUpAudioSession()
    }
    
    func loadAudio(with fileName: String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            try? audioPlayer.load(url: url)
            audioPlayer.play()
            audioPlayer.volume = 1
        }
    }
    
    func setUpAudioSession() {
        do {
            let audioSession = AudioKit.Settings.session
            try AudioKit.Settings.setSession(category: .playAndRecord,
                                             with: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func setupAudioEngine() {
        // Khởi tạo Audio Engine
        audioEngine = AudioEngine()
        
        // Lấy microphone input
        guard let input = audioEngine.input else { return }
        mic = input
        
        // Thêm FFT Tap để lấy dữ liệu FFT
        fftTap = FFTTap(mic) { fftData in
            DispatchQueue.main.async {
                self.analyzeFFTData(fftData)
            }
        }
        
        // Thiết lập FFT
        fftTap.isNormalized = false
        fftTap.start()
        
        // Thiết lập Echo Cancellation
        let echoCancellation = Fader(mic, gain: 1.0) // Giảm âm lượng để tránh tiếng vọng
        
        // Thiết lập mixer
        let mixer = Mixer(echoCancellation)
        audioEngine.output = mixer
        
        // Thiết lập recorder
        do {
            nodeRecorder = try NodeRecorder(node: mixer)
        } catch {
            Log("Không thể khởi tạo NodeRecorder: \(error)")
        }
        
        // Thiết lập player để phát lại file đã ghi
        recordPlayer = AudioPlayer()
        
        // Kích hoạt microphone input
        mixer.addInput(recordPlayer)
        mixer.addInput(audioPlayer)
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio Engine Error: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        do {
            try nodeRecorder.record()
        } catch {
            Log("Không thể bắt đầu ghi âm: \(error)")
        }
    }
    
    func stopRecording() {
        nodeRecorder.stop()
        audioPlayer.stop()
        if let file = nodeRecorder.audioFile {
            print("File ghi âm: \(file.url)")
            print("Thời lượng file: \(file.duration) giây")
        }
    }
    
    func playRecording() {
        guard let recordedFile = nodeRecorder?.audioFile else {
            print("Không có bản ghi để phát lại.")
            return
        }
        ensureAudioEngineRunning()
        recordPlayer.file = recordedFile
        recordPlayer.play()
        recordPlayer.volume = 1
        print("Đang phát lại bản ghi âm.")
    }
    
    func stop() {
        fftTap.stop()
        audioEngine.stop()
        audioPlayer.stop()
        nodeRecorder.stop()
    }
    
    private func restartEngineIfNeeded() {
        if !audioEngine.avEngine.isRunning {
            do {
                try audioEngine.start()
            } catch {
                print("Error restarting Audio Engine: \(error)")
            }
        }
    }
    
    private func ensureAudioEngineRunning() {
        if !audioEngine.avEngine.isRunning {
            do {
                try audioEngine.start()
                print("Audio Engine đã được khởi động lại.")
            } catch {
                print("Lỗi khi khởi động lại Audio Engine: \(error)")
            }
        }
    }
    
    private func analyzeFFTData(_ fftData: [Float]) {
        // Tìm giá trị lớn nhất trong FFT data (tần số trội)
        updateCounter += 1
        if updateCounter % 10 == 0 {
            restartEngineIfNeeded()
        } else {
            if let maxIndex = fftData.firstIndex(of: fftData.max() ?? 0) {
                let sampleRate = Float(audioEngine.input!.outputFormat.sampleRate)
                let frequency = Float(maxIndex) * sampleRate / Float(fftData.count)
                if frequency == 0 || frequency > Float(tones.first!.frequency) ||
                    frequency < Float(tones.last!.frequency) {
                    return
                }
                let midiNote = Int(round(69 + 12 * log2(frequency / 440.0)))
                let tone = getToneName(by: midiNote)
                let matchToneIndex = CGFloat(tones.firstIndex(where: {$0.midi == tone.midi}) ?? 0)
                delegate?.didUpdateFrequency(frequency: frequency, tone: tone, index: matchToneIndex)
            }
        }
    }
    
    func seek(isNext: Bool = true, seconds: TimeInterval = 10) {
        let seekTime = max(audioPlayer.currentTime - (isNext ? -seconds : seconds), 0)
        audioPlayer.seek(time: seekTime)
    }
}
