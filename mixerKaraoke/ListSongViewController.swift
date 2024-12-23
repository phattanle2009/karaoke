//
//  ListSongViewController.swift
//  mixerKaraoke
//
//  Created by Tan Phat LE on 25/11/24.
//

import UIKit

class ListSongViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let songsName = ["AMonsterLikeMe", "Androgyne", "BurningHeart",
                             "GangnamStyle", "IfINeverSeeYourFaceAgain",
                             "JustTheWayYouAre", "Maps", "Memories", "Misery"]
    private var songs: [UltraStarSong] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchSongs()
    }
    
    private func fetchSongs() {
        songsName.forEach { named in
            if let filePath = Bundle.main.path(forResource: named, ofType: "txt"),
               let lrcString = try? String(contentsOfFile: filePath, encoding: .utf8) {
                var song = UltraStarUtils.shared.parseUltraStarFile(lrcString)
                song.fileName = named
                songs.append(song)
            }
        }
    }
}

extension ListSongViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        cell.textLabel?.text = songs[indexPath.row].title
        cell.textLabel?.font = .boldSystemFont(ofSize: 16.0)
        cell.detailTextLabel?.text = songs[indexPath.row].artist
        cell.textLabel?.textAlignment = .left
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            .instantiateViewController(withIdentifier: "DetailPitchesViewController") as? DetailPitchesViewController
        vc?.modalPresentationStyle = .overFullScreen
        vc?.song = songs[indexPath.row]
        present(vc!, animated: true)
    }
}
