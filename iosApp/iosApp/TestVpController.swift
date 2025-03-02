//
//  Untitled.swift
//  iosApp
//
//  Created by Valdo on 27.02.2025.
//

import UIKit
import AVKit

class FullscreenVideoPlayerViewController: UIViewController {
    
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("vp loaded")
        playVideo()
        
        
    }
    
    private func playVideo() {
        guard let videoURL = videoURL else {
            print("Invalid video URL")
            return
        }
        
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        // Start playing when presented
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

        present(playerViewController, animated: true) {
            player.play()
        }
        
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video finished playing")
    }
}
