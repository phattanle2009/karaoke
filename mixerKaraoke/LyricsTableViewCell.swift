//
//  LyricsTableViewCell.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 2/12/24.
//

import UIKit

class LyricsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var karaokeTextContainer: UIStackView!
    
    var coloredTag = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        isUserInteractionEnabled = false
    }
    
    func configCell(data: [UltraStarWord], isHighlight: Bool, currentTime: TimeInterval) {
        karaokeTextContainer.arrangedSubviews.forEach { subview in
            karaokeTextContainer.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        coloredTag = 0
        for (syllablesIdx, syllables) in data.enumerated() {
            let hasUnderCore = !isHighlight
            ? isHighlight : currentTime >= syllables.startTime && coloredTag == syllablesIdx
            drawLyrics(word: syllables.word,
                       tag: syllablesIdx,
                       isHighlight: isHighlight,
                       hasUnderCore: hasUnderCore)
            coloredTag = syllablesIdx == data.count - 1 ? syllablesIdx : syllablesIdx + 1
            
            if currentTime > syllables.startTime && isHighlight {
                karaokeTextContainer.arrangedSubviews.forEach { subview in
                    if let vStack = subview as? UIStackView, subview.tag < syllablesIdx {
                        vStack.arrangedSubviews.last?.backgroundColor = .clear // ẩn undercore cũ đi
                    }
                }
            }
        }
    }
    
    private func drawLyrics(word: String,
                            tag: Int,
                            isHighlight: Bool,
                            hasUnderCore: Bool) {
        let vStack = UIStackView()
        vStack.tag = tag
        vStack.axis = .vertical
        vStack.distribution = .fill
        vStack.alignment = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.textColor = .black
        label.text = word
        label.font = isHighlight ? .boldSystemFont(ofSize: 14.0) : .italicSystemFont(ofSize: 14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let highlight = UILabel()
        highlight.backgroundColor = hasUnderCore ? .cyan : .clear
        highlight.translatesAutoresizingMaskIntoConstraints = false
        highlight.heightAnchor.constraint(equalToConstant: 4.0).isActive = true
        
        vStack.addArrangedSubview(label)
        vStack.addArrangedSubview(highlight)
        
        karaokeTextContainer.addArrangedSubview(vStack)
    }
}
