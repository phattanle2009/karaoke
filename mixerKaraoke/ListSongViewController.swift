//
//  ListSongViewController.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 25/11/24.
//

import UIKit

class ListSongViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ListSongViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        cell.textLabel?.text = "Kjetil Mørland & Debrah Scarlett - A Monster Like Me"
        cell.textLabel?.textAlignment = .left
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "DetailPitchesViewController") as? DetailPitchesViewController
        present(vc!, animated: true)
    }
}
