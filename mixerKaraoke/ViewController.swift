//
//  ViewController.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 22/11/24.
//

import UIKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func goToLyricsDetailView(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "DetailLyricsViewController") as? DetailLyricsViewController
        present(vc!, animated: true)
    }
    
    @IBAction func goToListOfSong(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "ListSongViewController") as? ListSongViewController
        present(vc!, animated: true)
    }
}
