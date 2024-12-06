//
//  PitchGraphView.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 27/11/24.
//

import UIKit

class PitchGraphView: UIView {
    
    var lines: [UltraStarLine] = []
    
    override func draw(_ rect: CGRect) {
        let barHeight: CGFloat = 10
        let barWidth: CGFloat = 200.0
        let hStack = UIStackView()
        hStack.spacing = 4
        hStack.alignment = .fill
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        for line in lines {
            for (index, pitch) in line.syllables.enumerated() {
                let width = barWidth * pitch.duration
                let pitchY = CGFloat(pitch.pitch * 6) + 50 // 50 is padding
                
                let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 160.0))
                container.translatesAutoresizingMaskIntoConstraints = false
                container.tag = index
                hStack.addArrangedSubview(container)
                
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
                
                guard let context = UIGraphicsGetCurrentContext() else { return }
                let fillColor = pitch.word.isEmpty ? UIColor.systemGreen.cgColor : UIColor.systemYellow.cgColor
                context.setFillColor(fillColor)
                context.fill(CGRect(x: 0, y: pitchY, width: width, height: barHeight))
                context.setBlendMode(.difference)
            }
        }
        
        addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
        ])
    }
}
