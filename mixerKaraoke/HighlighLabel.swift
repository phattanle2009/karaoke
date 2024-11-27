//
//  HighlighLabel.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 26/11/24.
//

import UIKit

class HighlighLabel: UILabel {
    
    init(title: String, isHighlight: Bool) {
        super.init(frame: .zero)
        self.initView(title: title, isHighlight: isHighlight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView(title: String, isHighlight: Bool) {
        // init titleLabel
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = isHighlight ? .systemRed : .black
    }
}
