//
//  PlayerViewController.swift
//  iosApp
//
//  Created by Valdo on 05.03.2025.
//

import UIKit
import AVFoundation
import shared

class PlayerViewController: UIViewController {

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    private let item: MediaItem

    init(_ item: MediaItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // ✅ Set background to black

        setupPlayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds // ✅ Ensure video fills screen
    }

    private func setupPlayer() {
        guard let url = URL(string: item.resolvedContentLink) else {
            fatalError("Invalid URL")
        }

        // Set AVAsset HTTP headers
        let assetOptions: [String: Any] = [
            "AVURLAssetHTTPHeaderFieldsKey": item.headers
        ]

        // Create an AVURLAsset with custom headers
        let asset = AVURLAsset(url: url, options: assetOptions)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect // ✅ Maintain aspect ratio

        if let playerLayer = playerLayer {
            view.layer.addSublayer(playerLayer) // ✅ Add video to view
        }

        player?.play() // ✅ Start playback
//        player?.obser
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause() // ✅ Stop playback when dismissing
    }

}
