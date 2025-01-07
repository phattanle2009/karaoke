//
//  MixerViewController.swift
//  mixerKaraoke
//
//  Created by tanphat.le on 2/1/25.
//

import UIKit

protocol MixerDelegate {
    func didChangeVolumeValue(vocal: Float, music: Float)
}

class MixerViewController: UIViewController {
    
    @IBOutlet weak var voiceValueLabel: UILabel!
    @IBOutlet weak var musicValueLabel: UILabel!
    @IBOutlet weak var voiceVolumeSlider: UISlider!
    @IBOutlet weak var musicVolumeSlider: UISlider!
    
    var delegate: MixerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [voiceVolumeSlider, musicVolumeSlider].forEach {
            $0?.minimumValue = 0.0
            $0?.maximumValue = 100.0
            $0?.value = 50.0
        }
    }
    
    deinit {
        delegate = nil
    }
    
    @IBAction func didVoiceVolumeChange(_ sender: Any) {
        if let slider = sender as? UISlider {
            voiceValueLabel.text = "\(Int(slider.value))%"
        }
    }
    
    @IBAction func didMusicVolumeChange(_ sender: Any) {
        if let slider = sender as? UISlider {
            musicValueLabel.text = "\(Int(slider.value))%"
        }
    }
    
    @IBAction func tapOnExportButton(_ sender: Any) {
        delegate?.didChangeVolumeValue(vocal: voiceVolumeSlider.value / 10,
                                       music: musicVolumeSlider.value / 10)
        dismiss(animated: true)
    }
}
