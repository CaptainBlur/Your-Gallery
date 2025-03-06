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
    private var timeObserverToken: Any?

    private let progressBar: UIProgressView = UIProgressView(progressViewStyle: .default)
    private let seekAreaView: UIView = UIView()
    private let timeCounterLabel = UILabel()
    
    private var startSeeking = false
    private var startSeekPosition: CGFloat = 0.0
    private var startSeekSeconds: Float64 = 0.0
    
    private let playButton = UIButton()
    private let previousButton = UIButton()
    private let nextButton = UIButton()
    


    private let item: MediaItem
    private let colorScheme: MediaTypeColorScheme

    init(_ item: MediaItem) {
        self.item = item
        self.colorScheme = item.containerType.colorScheme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Native().sl.f(msg: "Player screen loaded")

        view.backgroundColor = .black

        setupPlayer()
        setupControlViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }



    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Native().sl.f(msg: "Player screen unloaded")
        player?.pause()
        removeObservers()
    }

}

extension PlayerViewController{
    private func setupControlViews(){
        //Time counter
        timeCounterLabel.text = "--:--"
        timeCounterLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        timeCounterLabel.textColor = colorScheme.surfaceContainerLowest.uiColorLight()
        timeCounterLabel.alpha = 0
        timeCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeCounterLabel)
        
        //Progress bar
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.setProgress(0.0, animated: false)
        progressBar.trackTintColor = colorScheme.outlineVariant.uiColor().withAlphaComponent(0.85)
        progressBar.progressTintColor = colorScheme.tertiaryContainer.uiColor().withAlphaComponent(0.95)
        view.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -72),
            progressBar.heightAnchor.constraint(equalToConstant: 6),
            
            timeCounterLabel.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
            timeCounterLabel.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor, constant: -10)
        ])
        
        //Seek area
        seekAreaView.translatesAutoresizingMaskIntoConstraints = false
        seekAreaView.backgroundColor = UIColor.clear
        seekAreaView.isUserInteractionEnabled = true
        view.addSubview(seekAreaView)

        NSLayoutConstraint.activate([
            seekAreaView.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            seekAreaView.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor),
            seekAreaView.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
            seekAreaView.heightAnchor.constraint(equalToConstant: 52)
        ])

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSeekGesture(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProgressTap(_:)))

        seekAreaView.addGestureRecognizer(panGesture)
        seekAreaView.addGestureRecognizer(tapGesture)
        tapGesture.require(toFail: panGesture)
        
        //Buttons
        let playbackButtonsColor = colorScheme.surfaceContainerHigh.uiColorLight().withAlphaComponent(0.88)
        let playConfig = UIImage.SymbolConfiguration(pointSize: 45, weight: .bold)
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold)
        playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playConfig), for: .normal)
        previousButton.setImage(UIImage(systemName: "backward.fill", withConfiguration: config), for: .normal)
        nextButton.setImage(UIImage(systemName: "forward.fill", withConfiguration: config), for: .normal)
        
        playButton.tintColor = playbackButtonsColor
        playButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        
        previousButton.tintColor = playbackButtonsColor
        previousButton.addTarget(self, action: #selector(skipBackward), for: .touchUpInside)
        
        nextButton.tintColor = playbackButtonsColor
        nextButton.addTarget(self, action: #selector(skipForward), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [previousButton, playButton, nextButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .equalSpacing
        buttonStack.spacing = 55
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }
    
    @objc private func handleSeekGesture(_ gesture: UIPanGestureRecognizer) {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        let location = gesture.translation(in: seekAreaView)
        let progressWidth = seekAreaView.bounds.width
        
        let positionDelta = location.x - startSeekPosition
        let secondsDelta = durationSeconds / progressWidth * positionDelta * 0.35
        let newSeconds = startSeekSeconds + secondsDelta
        let newTime = CMTime(seconds: newSeconds, preferredTimescale: 600)
        let tolerance: CMTime = CMTime(seconds: 0.5, preferredTimescale: 600)

        switch gesture.state {
        case .began:
            startSeekPosition = location.x
            startSeekSeconds = CMTimeGetSeconds(player.currentTime())
            startSeeking = true
//            Native().sl.i(msg: "⏩ Seeking started")
        case .changed:
//            Native().sl.i(msg: "progress \(positionDelta): \(secondsDelta) seconds")
            player.seek(to: newTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
            progressBar.progress = Float(newSeconds / durationSeconds)
//            Native().sl.i(msg: "⏩ Seeking to \(CMTimeGetSeconds(newTime)) seconds")
        case .ended:
//            player.pause()
//            player.play()
            Task{
                try await Task.sleep(for:.seconds(2))
                startSeeking = false
            }
//            Native().sl.i(msg: "⏩ Seeking finished at \(CMTimeGetSeconds(newTime)) seconds")
        default:
            break
        }
    }
    
    @objc private func handleProgressTap(_ gesture: UITapGestureRecognizer) {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        let durationSeconds = CMTimeGetSeconds(duration)
        let location = gesture.location(in: seekAreaView)
        let progressWidth = seekAreaView.bounds.width
        let percentage = max(0, min(1, location.x / progressWidth))
        let newTime = CMTime(seconds: Double(percentage) * durationSeconds, preferredTimescale: 600)

        startSeeking = true
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        progressBar.setProgress(Float(percentage), animated: false)
//        player.pause()
//        player.play()
        //MARK: use task group for handling active 'unlocking' tasks
        Task{
            try await Task.sleep(for:.seconds(2))
            startSeeking = false
        }
//        Native().sl.i(msg: "⏩ Jumped to \(CMTimeGetSeconds(newTime)) seconds")
    }
    
    @objc private func togglePlayPause() {
        guard let player = player else { return }
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .bold)
        let playIcon = UIImage(systemName: "play.fill", withConfiguration: config)
        let pauseIcon = UIImage(systemName: "pause.fill", withConfiguration: config)

        if player.timeControlStatus == .playing {
            player.pause()
            playButton.setImage(playIcon, for: .normal)
        } else {
            player.play()
            playButton.setImage(pauseIcon, for: .normal)
        }
    }


    @objc private func skipBackward() {
//        guard let player = player else { return }
//        let currentTime = CMTimeGetSeconds(player.currentTime())
//        let newTime = max(0, currentTime - 10)
//        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    }

    @objc private func skipForward() {
//        guard let player = player, let duration = player.currentItem?.duration else { return }
//        let currentTime = CMTimeGetSeconds(player.currentTime())
//        let durationSeconds = CMTimeGetSeconds(duration)
//        let newTime = min(durationSeconds, currentTime + 10)
//        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    }
}

extension PlayerViewController {
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

        addObservers()
        playerItem.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        
        player?.play() // ✅ Start playback
//        player?.obser
    }
    
    private func addObservers() {
        // 🔹 Observe playback state
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .initial], context: nil)

        // 🔹 Track video completion
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

        // 🔹 Track playback progress
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { time in
            guard let duration = self.player?.currentItem?.duration else { return }

            let durationSeconds = CMTimeGetSeconds(duration)
            let currentSeconds = CMTimeGetSeconds(time)
            let remainingTime = durationSeconds - currentSeconds

            if remainingTime.isFinite {
                self.timeCounterLabel.text = self.formatTime(seconds: Int(remainingTime))
            }

            guard !self.startSeeking else { return }
            if durationSeconds > 0 {
                let progress = Float(currentSeconds / durationSeconds)
                self.progressBar.setProgress(progress, animated: true)
//                Native().sl.i(msg: "🟢 Progress updated: \(progress)")
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "timeControlStatus" {
//            if let player = object as? AVPlayer {
//                switch player.timeControlStatus {
//                case .playing:
//                    Native().sl.fr(msg: "▶️ Player")
//                case .paused:
//                    Native().sl.fr(msg: "⏸️ Player")
//                case .waitingToPlayAtSpecifiedRate:
//                    Native().sl.fr(msg: "⏳ Player")
//                @unknown default:
//                    Native().sl.fr(msg: "❓ Player")
//                }
//            }
//        } else
        if keyPath == "status", let playerItem = object as? AVPlayerItem {
            switch playerItem.status {
            case .readyToPlay:
                Native().sl.fr(msg: "Media successfully resolved")
                animateTimeCounter()
                player?.play()
            case .failed:
                Native().sl.w(msg: "Failed to load media: \(playerItem.error?.localizedDescription ?? "Unknown error")")
            case .unknown:
                Native().sl.fr(msg: "PlayerItem status unknown")
            @unknown default:
                Native().sl.w(msg: "Unhandled AVPlayerItem status")
            }
        }
    }
    
    private func animateTimeCounter() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.timeCounterLabel.alpha = 1
            self.timeCounterLabel.transform = CGAffineTransform(translationX: 0, y: 25)
        })
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "-%02d:%02d", minutes, seconds)
    }

    
    @objc private func playerDidFinishPlaying() {
        Native().sl.i(msg: "🏁 Video playback completed")
        dismiss(animated: true)
    }

    // ✅ Cleanup observers
    private func removeObservers() {
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self)

        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
    }
}
