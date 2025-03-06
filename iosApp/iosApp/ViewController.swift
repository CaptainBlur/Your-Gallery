//
//  ViewController.swift
//  iosApp
//
//  Created by Valdo on 24.02.2025.
//

import UIKit
import AVKit
import shared

class ViewController: UIViewController {
    
    let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        addSampleText()

        NotificationCenter.default.addObserver(self, selector: #selector(handleSharedURL(_:)), name: .sharedURLReceived, object: nil)
    }
    
    func addSampleText(){
        view.backgroundColor = .white
        
        //let text = Greeting().greet()
        let text = ""
        
        // Create a UITextView
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.textColor = .black
        textView.backgroundColor = .lightGray
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.darkGray.cgColor
        
        // Add UITextView to the view
        view.addSubview(textView)
        
        // Set Constraints
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            textView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    
    func createAVPlayerWithHeaders(videoUrl: String, headers: [String: String]) -> AVPlayer {
        guard let url = URL(string: videoUrl) else {
            fatalError("Invalid URL")
        }

        // Set AVAsset HTTP headers
        let assetOptions: [String: Any] = [
            "AVURLAssetHTTPHeaderFieldsKey": headers
        ]

        // Create an AVURLAsset with custom headers
        let asset = AVURLAsset(url: url, options: assetOptions)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)

        return player
    }
    
    @objc private func handleSharedURL(_ notification: Notification) {
        if let url = notification.object as? URL {
            print("📌 ViewController received shared URL: \(url.absoluteString)")
            textView.text = "Received URL:\n\(url.absoluteString)"
        }
    }

}

