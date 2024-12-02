//
//  PitchDetector.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 28/11/24.
//

import AVFoundation

class PitchDetector {
    
    private let audioEngine = AVAudioEngine()
    private let inputNode: AVAudioInputNode
    private let bus: AVAudioNodeBus = 0
    private let bufferSize: AVAudioFrameCount = 1024
    private let minPitch: Float = 80.0   // Ngưỡng pitch thấp nhất
    private let maxPitch: Float = 1000.0 // Ngưỡng pitch cao nhất
    
    var currentPitch: Float = 0.0
    private let amplitudeThreshold: Float = 0.01  // Ngưỡng biên độ
    
    init() {
        inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: bus)
        
        inputNode.installTap(onBus: bus, bufferSize: bufferSize, format: format) { (buffer, _) in
            self.detectPitch(from: buffer)
        }
        
        try? audioEngine.start()
    }
    
    private func detectPitch(from buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
        
        // Tính toán biên độ trung bình
        let amplitude = channelDataArray.map { abs($0) }.reduce(0, +) / Float(buffer.frameLength)
        
        // Bỏ qua nếu biên độ dưới ngưỡng
        if amplitude < amplitudeThreshold {
            return
        }
        
        // Triển khai logic phát hiện pitch ở đây (FFT hoặc autocorrelation)
        let pitch = calculateFrequency(from: channelDataArray)
        
        // Kiểm tra pitch có nằm trong ngưỡng không
        if pitch < minPitch || pitch > maxPitch {
            return  // Bỏ qua giá trị không hợp lệ
        }
        
        DispatchQueue.main.async {
            self.currentPitch = pitch
        }
    }
    
    private func calculateFrequency(from samples: [Float]) -> Float {
        // Placeholder cho logic phát hiện pitch (FFT, autocorrelation, ...)
        return Float.random(in: 80...1000)  // Giá trị giả lập
    }
}
