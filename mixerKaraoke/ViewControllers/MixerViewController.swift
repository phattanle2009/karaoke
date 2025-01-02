//
//  MixerViewController.swift
//  mixerKaraoke
//
//  Created by tanphat.le on 2/1/25.
//

import UIKit

protocol MixerDelegate {
    func didChangeVolumeValue(vocal: Int, music: Int)
}

class MixerViewController: UIViewController {
    
    @IBOutlet weak var voiceValueLabel: UILabel!
    @IBOutlet weak var musicValueLabel: UILabel!
    
    private var voiceValue = 0
    private var musicValue = 0
    
    var delegate: MixerDelegate?
    
    deinit {
        delegate = nil
    }
    
    @IBAction func didVoiceVolumeChange(_ sender: Any) {
        if let slider = sender as? UISlider {
            voiceValue = Int(slider.value * 100)
            voiceValueLabel.text = "\(voiceValue)%"
        }
    }
    
    @IBAction func didMusicVolumeChange(_ sender: Any) {
        if let slider = sender as? UISlider {
            musicValue = Int(slider.value * 100)
            musicValueLabel.text = "\(musicValue)%"
        }
    }
    
    @IBAction func tapOnExportButton(_ sender: Any) {
        delegate?.didChangeVolumeValue(vocal: voiceValue, music: musicValue)
        dismiss(animated: true)
    }
}
