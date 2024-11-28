//
//  PitchGraphView.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 27/11/24.
//

import UIKit

class PitchGraphView: UIView {
    
    var pitchData: [UltraStarWord] = []

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let barHeight: CGFloat = 10
        let barWidth: CGFloat = 10
        var startX: CGFloat = 0
        
        for pitch in pitchData {
            let width = barWidth * pitch.duration
            let pitchY = CGFloat(pitch.pitch * 5) + 50 // 50 is padding
            
            context.setFillColor(UIColor.systemBlue.cgColor)
            let barRect = CGRect(x: startX, y: pitchY, width: width, height: barHeight)
            context.fill(barRect)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineBreakMode = .byTruncatingTail
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.black
            ]
            
            pitch.word.draw(with: CGRect(x: startX, y: pitchY - 20, width: width, height: 20),
                            options: .usesLineFragmentOrigin,
                            attributes: attributes,
                            context: nil)
            
            startX = startX + width + 10 // 10 is spacing
        }
    }
}
