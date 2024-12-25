//
//  DetailPitchesViewController.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 25/11/24.
//

import UIKit
import Foundation

class DetailPitchesViewController: UIViewController {
    
    @IBOutlet weak var nameOfSongLabel: UILabel!
    @IBOutlet weak var lyricsTableView: UITableView!
    @IBOutlet weak var pitchGraphScrollView: UIScrollView!
    @IBOutlet weak var pitchGraphView: UIStackView!
    @IBOutlet weak var blendColorView: UIView!
    @IBOutlet weak var pitchDetectorLabel: UILabel!
    @IBOutlet weak var bottomButtonWrapper: UIStackView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pitchArrow: UIImageView!
    // Constraint
    @IBOutlet weak var pitchArrow_TCT: NSLayoutConstraint!
    @IBOutlet weak var pitchGraphScrollView_HCT: NSLayoutConstraint!
    
    // song logic
    var song: UltraStarSong!
    private var currentLine = 0
    private var xOffset: CGFloat = 0
    private var stepScrollOffset: CGFloat = 0
    private var timer: DispatchSourceTimer?
    private var audioManager = AudioManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lyricsTableView.register(UINib(nibName: "LyricsTableViewCell", bundle: .main),
                                 forCellReuseIdentifier: "LyricsTableViewCell")
        lyricsTableView.delegate = self
        lyricsTableView.dataSource = self
        
        setupUI()
        audioManager.tones = song.tones
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.audioManager.loadAudio(with: strongSelf.song.fileName)
            strongSelf.startLyricsSync()
            strongSelf.audioManager.startRecording()
        }
        audioManager.setupAudioEngine()
        audioManager.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioManager.stop()
    }
    
    private func setupUI() {
        // name
        nameOfSongLabel.text = song.title
        
        // lyrics list and pitch graph
        [lyricsTableView, pitchGraphScrollView].forEach {
            $0?.layer.cornerRadius = 10.0
            $0?.layer.borderWidth = 2.0
            $0?.layer.borderColor = UIColor.lightGray.cgColor
        }
        let left = CGFloat((UIScreen.main.bounds.size.width - 24) / 3)
        pitchGraphScrollView.contentInset = UIEdgeInsets(top: 0.0, left: left, bottom: 0.0, right: 0.0)
        
        // pitch level
        pitchDetectorLabel.text = "Current Pitch: -- Hz"
        pitchDetectorLabel.textAlignment = .center
        pitchDetectorLabel.font = UIFont.systemFont(ofSize: 24)
        
        // bottom button wrapper
        bottomButtonWrapper.layer.cornerRadius = 10
        
        blendColorView.layer.compositingFilter = "hueBlendMode"
        
        drawPitchGraph()
    }
    
    private func drawPitchGraph() {
        pitchGraphScrollView_HCT.constant = CGFloat(song.tones.count) * 20.0
        UltraStarUtils.shared.drawPitchGraph(with: song, to: pitchGraphView)
    }
    
    private func startLyricsSync() {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: 0.01)
        timer?.setEventHandler {
            if self.audioManager.audioPlayer.isPlaying {
                let currentTime = self.audioManager.audioPlayer.currentTime
                for (lineIdx, line) in self.song.lines.enumerated() {
                    if lineIdx + 1 < self.song.lines.count {
                        let nextTime = self.song.lines[lineIdx + 1].syllables.first!.startTime
                        if currentTime >= line.syllables.first!.startTime && currentTime < nextTime {
                            self.currentLine = lineIdx
                            self.scrollToCurrentLine()
                            break
                        }
                    } else if currentTime >= line.syllables.first!.startTime {
                        self.currentLine = lineIdx
                        self.scrollToCurrentLine()
                    }
                }
                let scale = UIScreen.main.scale
                
                if self.stepScrollOffset == 0 {
                    // cứ mỗi 0.01 giây nó cần scroll thêm chừng này offset
                    self.stepScrollOffset = self.pitchGraphScrollView.contentSize.width / CGFloat(self.audioManager.audioPlayer.duration * 100)
                    self.stepScrollOffset = round(self.stepScrollOffset * scale) / scale
                }
                let leftInset = self.pitchGraphScrollView.frame.width / 3
                let offsetX = (round(currentTime * 100 * self.stepScrollOffset * scale) / scale) - leftInset
                self.scrollPitchGraph(to: offsetX)
            }
        }
        timer?.resume()
    }
    
    private func scrollPitchGraph(to offset: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.pitchGraphScrollView.contentOffset.x = offset
            }
        }
    }
    
    @IBAction func tapOnPrevButton(_ sender: Any) {
        xOffset = xOffset - stepScrollOffset * 1000
        xOffset = xOffset <= 0 ? 0 : xOffset
        audioManager.playbackTime(isNext: false)
    }
    
    @IBAction func tapOnPauseButton(_ sender: Any) {
        if let audioPlayer = audioManager.audioPlayer {
            if audioPlayer.isPlaying {
                self.audioManager.audioPlayer.pause()
                self.audioManager.nodeRecorder.pause()
                pauseButton.setImage(UIImage(systemName: "play.circle"),
                                     for: .normal)
            } else {
                self.audioManager.audioPlayer.play()
                self.audioManager.nodeRecorder.resume()
                pauseButton.setImage(UIImage(systemName: "pause.circle"),
                                     for: .normal)
            }
        }
    }
    
    @IBAction func tapOnNextButton(_ sender: Any) {
        xOffset = xOffset + stepScrollOffset * 1000
        xOffset = xOffset >= pitchGraphScrollView.contentSize.width ? pitchGraphScrollView.contentSize.width : xOffset
        audioManager.playbackTime()
    }
    
    @IBAction func tapOnBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func tapOnRecordButton(_ sender: Any) {
        if audioManager.audioPlayer.isPlaying {
            audioManager.audioPlayer.pause()
            audioManager.nodeRecorder.pause()
            
            let alert = UIAlertController(
                title: "Would you like to stop the recording?",
                message: "The app is recording your voice and the music. After stopped, hit again on voice button to playback the record",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Yes, stop it", style: .default, handler: { _ in
                self.audioManager.stopRecording()
            }))
            alert.addAction(UIAlertAction(title: "Resume", style: .cancel, handler: { _ in
                self.audioManager.audioPlayer.prepareToPlay()
                self.audioManager.audioPlayer.play()
                self.audioManager.nodeRecorder.resume()
                self.dismiss(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            audioManager.playRecording()
        }
    }
}

// MARK: - AudioManager
extension DetailPitchesViewController: AudioManagerDelegate {
    
    func didUpdateFrequency(frequency: Float, tone: Tone, index: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1) {
                self.pitchDetectorLabel.text = "Pitch: \(Int(frequency)) Hz - Tone: \(tone.pitch)"
                self.pitchArrow.transform = CGAffineTransform(translationX: 0, y: index * 20.0)
            }
        }
    }
}

// MARK: - Table view
extension DetailPitchesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollToCurrentLine() {
        let indexPath = IndexPath(row: currentLine, section: 0)
        lyricsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        lyricsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return song.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LyricsTableViewCell",
                                                       for: indexPath) as? LyricsTableViewCell
        else { return .init() }
        let data = song.lines[indexPath.row]
        let isHighlight = indexPath.row == currentLine
        guard let player = audioManager.audioPlayer else { return .init() }
        let currentTime = player.currentTime
        cell.configCell(data: data.syllables, isHighlight: isHighlight, currentTime: currentTime)
        return cell
    }
}
