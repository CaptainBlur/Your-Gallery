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
    private var currentItem: AVPlayerItem?
    
    private let controlsContainerView: UIView = UIView()
    private let gradientView: UIView = UIView()
    private let progressBar: UIProgressView = UIProgressView(progressViewStyle: .default)
    private let seekAreaView: UIView = UIView()
    private let timeCounterLabel = UILabel()
    
    private var blockPlayerProgressSet = false
    private var startSeekPosition: CGFloat = 0.0
    private var startSeekSeconds: Float64 = 0.0
    
    private let playButton = UIButton()
    private let previousButton = UIButton()
    private let nextButton = UIButton()
    private let closeButton = UIButton()
    private let unablePlayImage = UIImageView()
    
    private var playerProgressSetTask: Task<Void, Error> = Task(){}
    private var playerControlsHideTask: Task<Void, Error> = Task(){}
    private var playerLoadingIndicationTask: Task<Void, Error> = Task(){}
    
    private let playbackType: Int8
    private let item: MediaItem?
    private let container: MediaContainer?
    private let colorScheme: MediaTypeColorScheme

    init(_ item: MediaItem) {
        playbackType = 0
        self.item = item
        self.container = nil
        self.colorScheme = item.containerType.colorScheme
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ container: MediaContainer){
        playbackType = 1
        self.container = container
        self.item = nil
        self.colorScheme = container.containerType.colorScheme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Native().sl.f(msg: "Player screen loaded")

        view.backgroundColor = .black

        setupPlayback()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
        gradientView.layer.sublayers?.first?.frame = gradientView.bounds
    }



    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Native().sl.f(msg: "Player screen unloaded")
        player?.pause()
    }

}


extension PlayerViewController {
    
    private func setupControlViews(){
        //Controls container
        controlsContainerView.alpha = 1
        controlsContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsContainerView)
        
        NSLayoutConstraint.activate([
            controlsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            controlsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        view.addGestureRecognizer(tapGesture)
        
        //Gradient view
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        view.addSubview(gradientView)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.45).cgColor, // Dark at the bottom
            UIColor.clear.cgColor // Transparent at the top
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.frame = gradientView.bounds

        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 135)
        ])
        
        //Time counter
        timeCounterLabel.text = "--:--"
        timeCounterLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        timeCounterLabel.textColor = colorScheme.surfaceContainerLowest.uiColorLight()
        timeCounterLabel.alpha = 0
        timeCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        controlsContainerView.addSubview(timeCounterLabel)
        
        //Progress bar
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.setProgress(0.0, animated: false)
        progressBar.trackTintColor = colorScheme.surfaceContainerHigh.uiColor().withAlphaComponent(0.85)
        progressBar.progressTintColor = colorScheme.tertiaryContainer_medium.uiColor().withAlphaComponent(0.95)
        controlsContainerView.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -20),
            progressBar.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -65),
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

        let progressPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSeekGesture(_:)))
        let progressTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProgressTap(_:)))

        seekAreaView.addGestureRecognizer(progressPanGesture)
        seekAreaView.addGestureRecognizer(progressTapGesture)
        progressTapGesture.require(toFail: progressPanGesture)
        
        //Unable to play image
        let symbolConfig = UIImage.SymbolConfiguration(hierarchicalColor: colorScheme.surfaceContainerHigh.uiColorLight())
        unablePlayImage.image = UIImage(systemName: "play.slash.fill", withConfiguration: symbolConfig)
        unablePlayImage.translatesAutoresizingMaskIntoConstraints = false
        unablePlayImage.isHidden = true
        view.addSubview(unablePlayImage)

        NSLayoutConstraint.activate([
            unablePlayImage.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            unablePlayImage.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            unablePlayImage.widthAnchor.constraint(equalToConstant: 45),
            unablePlayImage.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        
        //Buttons
        let playbackButtonsColor = colorScheme.surfaceContainerHigh.uiColorLight().withAlphaComponent(0.88)
        let playConfig = UIImage.SymbolConfiguration(pointSize: 45, weight: .semibold)
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .semibold)
        playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playConfig), for: .normal)
        playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playConfig), for: .highlighted)
        previousButton.setImage(UIImage(systemName: "backward.fill", withConfiguration: config), for: .normal)
        previousButton.setImage(UIImage(systemName: "backward.fill", withConfiguration: config), for: .highlighted)
        nextButton.setImage(UIImage(systemName: "forward.fill", withConfiguration: config), for: .normal)
        nextButton.setImage(UIImage(systemName: "forward.fill", withConfiguration: config), for: .highlighted)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)), for: .normal)
        
        playButton.tintColor = playbackButtonsColor
        playButton.addTarget(self, action: #selector(animateButtonDown(_:)), for: .touchDown)
        playButton.addTarget(self, action: #selector(togglePlayPause), for: [.touchUpInside, .touchUpOutside])
        playButton.translatesAutoresizingMaskIntoConstraints = false
//        playButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        
        previousButton.tintColor = playbackButtonsColor
        previousButton.addTarget(self, action: #selector(animateButtonDown(_:)), for: .touchDown)
        previousButton.addTarget(self, action: #selector(skipBackward), for: .touchUpInside)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        
        nextButton.tintColor = playbackButtonsColor
        nextButton.addTarget(self, action: #selector(animateButtonDown(_:)), for: .touchDown)
        nextButton.addTarget(self, action: #selector(skipForward), for: .touchUpInside)
        if playbackType==0{
            nextButton.isHidden = true
        }
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.tintColor = colorScheme.surface.uiColorLight()
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        controlsContainerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 20)
        ])

        controlsContainerView.addSubview(previousButton)
        controlsContainerView.addSubview(playButton)
        controlsContainerView.addSubview(nextButton)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            
            previousButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            previousButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -55),
            
            nextButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 55)
        ])
    }
    
    private func setupPlayback(){
        switch playbackType{
        case 0:
            setupPlayer()
            setupControlViews()
            setupControlsHide()
        case 1:
            setupQueuePlayer{
                self.setupControlViews()
                self.setupControlsHide()
            }
        default:
            return
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: item!.resolvedContentLink), (item != nil) else {
            fatalError("Invalid URL")
        }
        
        Native().sl.i(msg: "setting up player for item: \(item!.name)")

        // Set AVAsset HTTP headers
        let assetOptions: [String: Any] = [
            "AVURLAssetHTTPHeaderFieldsKey": item!.headers
        ]

        // Create an AVURLAsset with custom headers
        let asset = AVURLAsset(url: url, options: assetOptions)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect

        if let playerLayer = playerLayer {
            view.layer.addSublayer(playerLayer)
        }

        addObservers()
        playerItem.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        
        player?.play()
    }
    
    private func setupQueuePlayer(onComplete: @escaping ()->Void){
        guard container != nil else { return }
        Task{
            let index = Int(container!.itemPointer)
            Native().sl.i(msg: "setting up player for item: \((container!.mediaItems[index] as! MediaItem).name)")
            
            var mediaQueue = container!.mediaItems
                if container!.itemPointer>0{
                    mediaQueue.removeSubrange(0..<index)
                }

            let playerItems: [AVPlayerItem] = mediaQueue.map {
                let item = $0 as! MediaItem
                
                guard let url = URL(string: item.resolvedContentLink) else {
                    fatalError("Invalid URL")
                }
                
                let assetOptions: [String: Any] = [
                    "AVURLAssetHTTPHeaderFieldsKey": item.headers
                ]

                // Create an AVURLAsset with custom headers
                let asset = AVURLAsset(url: url, options: assetOptions)
                return AVPlayerItem(asset: asset)
            }
                        
            player = AVQueuePlayer(items: playerItems)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspect

            if let playerLayer = playerLayer {
                view.layer.addSublayer(playerLayer)
            }
            
            onComplete()

            addObservers()
            observeNewItem(player?.currentItem)
            
            player?.play()
        }
    }
    
    private func observeNewItem(_ item: AVPlayerItem?) {
        // ✅ Remove observer from the old item
        if let currentItem = currentItem {
            currentItem.removeObserver(self, forKeyPath: "status")
        }
        
        // ✅ Set and observe the new item
        currentItem = item
        currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
    }

    
    private func removeObservers() {
        if playbackType==0{
            player?.currentItem?.removeObserver(self, forKeyPath: "status")
        }
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self)
        
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
        
        if playbackType==1, let currentItem = currentItem {
            currentItem.removeObserver(self, forKeyPath: "status")
        }
        NotificationCenter.default.removeObserver(self)
    }
}

extension PlayerViewController{
    private func addObservers() {
        // Observe playback state
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .initial], context: nil)

        // Track video completion
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidAdvanceToNextItem),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )

        // Track playback progress
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) {[weak self] time in
            guard self != nil, let duration = self!.player?.currentItem?.duration else { return }

            let durationSeconds = CMTimeGetSeconds(duration)
            let currentSeconds = CMTimeGetSeconds(time)
            let remainingTime = durationSeconds - currentSeconds

            if remainingTime.isFinite {
                self!.timeCounterLabel.text = self!.formatTime(seconds: Int(remainingTime))
            }

            guard !self!.blockPlayerProgressSet else { return }
            if durationSeconds > 0 {
                let progress = Float(currentSeconds / durationSeconds)
                self!.progressBar.setProgress(progress, animated: true)
//                Native().sl.i(msg: "🟢 Progress updated: \(progress)")
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if let player = object as? AVPlayer {
                switch player.timeControlStatus {
                case .playing:
                    removePulsatingAnimation()
//                    Native().sl.fr(msg: "▶️ Player")
                case .paused:
                    removePulsatingAnimation()
//                    Native().sl.fr(msg: "⏸️ Player")
                case .waitingToPlayAtSpecifiedRate:
                    setupPlayerLoadingIndication()
//                    Native().sl.fr(msg: "⏳ Player")
                @unknown default:
                    Native().sl.fr(msg: "❓ Player")
                }
            }
        } else
        if keyPath == "status", let playerItem = object as? AVPlayerItem {
            switch playerItem.status {
            case .readyToPlay:
                Native().sl.fr(msg: "Media successfully resolved")
                animateTimeCounter()
                player?.play()
            case .failed:
                Native().sl.w(msg: "Failed to load media: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                player?.pause()
                playButton.isHidden = true
                unablePlayImage.isHidden = false
                resetTimeCounter()
            case .unknown:
                Native().sl.fr(msg: "PlayerItem status unknown")
            @unknown default:
                Native().sl.w(msg: "Unhandled AVPlayerItem status")
            }
        }
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
            blockPlayerProgressSet = true
            playerControlsHideTask.cancel()
        case .changed:
            player.seek(to: newTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
            progressBar.progress = Float(newSeconds / durationSeconds)
        case .ended:
            setupProgressSetRelease()
            setupControlsHide()
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

        blockPlayerProgressSet = true
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        progressBar.setProgress(Float(percentage), animated: false)
        setupProgressSetRelease()
        setupControlsHide()
    }
    
    @objc private func togglePlayPause() {
        animateButtonUp(playButton)
        
        guard let player = player else { return }
        let playConfig = UIImage.SymbolConfiguration(pointSize: 45, weight: .semibold)
        let playIcon = UIImage(systemName: "play.fill", withConfiguration: playConfig)
        let pauseIcon = UIImage(systemName: "pause.fill", withConfiguration: playConfig)

        if player.timeControlStatus == .playing {
            player.pause()
            playButton.setImage(playIcon, for: .normal)
            playButton.setImage(playIcon, for: .highlighted)
        } else {
            player.play()
            playButton.setImage(pauseIcon, for: .normal)
            playButton.setImage(pauseIcon, for: .highlighted)
        }
        setupControlsHide()
    }

    @objc private func playerDidAdvanceToNextItem() {
        guard let queuePlayer = player as? AVQueuePlayer else { return }
        observeNewItem(queuePlayer.currentItem)
    }

    @objc private func skipBackward() {
        setupControlsHide()
        animateButtonUp(previousButton)
        
        player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        progressBar.setProgress(0.0, animated: false)
        blockPlayerProgressSet = true
        setupProgressSetRelease()
    }

    @objc private func skipForward() {
        setupControlsHide()
        animateButtonUp(nextButton)
        advanceToNextItem()
//        Native().sl.w(obj: queuePlayer.items())
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true)
    }
    
    private func resetTimeCounter(){
        UIView.animate(withDuration: 0.0) {
            self.timeCounterLabel.alpha = 0
            self.timeCounterLabel.transform = .identity // Resets to original state
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
        if (playbackType==0){
            dismiss(animated: true)
        } else {
            advanceToNextItem()
        }
    }
    
    private func advanceToNextItem(){
        guard let queuePlayer = player as? AVQueuePlayer else { return }
        
        player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        player?.play()
        progressBar.setProgress(0.0, animated: false)
        timeCounterLabel.text = "--:--"
        blockPlayerProgressSet = true
        setupProgressSetRelease()
        
        playButton.isHidden = false
        unablePlayImage.isHidden = true
        
        if queuePlayer.items().count > 1{
            guard let url = (queuePlayer.items()[1].asset as? AVURLAsset)?.url else {return}
            Native().sl.i(msg: "Advancing to next item: \(String(describing: url))")
            queuePlayer.advanceToNextItem()
            playerDidAdvanceToNextItem()
        }
        if queuePlayer.items().count == 1 {
            nextButton.isHidden = true
        }
    }

    private func setupProgressSetRelease(){
        playerProgressSetTask.cancel()
        playerProgressSetTask = Task{
            try await Task.sleep(for:.seconds(2))
            blockPlayerProgressSet = false
        }
    }
    
    @objc private func handleTapGesture() {
        let isHidden = controlsContainerView.alpha == 0

        UIView.animate(withDuration: 0.25, animations: {
            self.controlsContainerView.alpha = isHidden ? 1 : 0
            self.gradientView.alpha = isHidden ? 1 : 0
        })

        if isHidden {
            setupControlsHide()
        }
    }

    private func setupControlsHide(){
        playerControlsHideTask.cancel()
        playerControlsHideTask = Task{
            try await Task.sleep(for:.seconds(5))
            UIView.animate(withDuration: 0.25, animations: {
                self.controlsContainerView.alpha = 0
                self.gradientView.alpha = 0
            })
        }
    }
    
    private func setupPlayerLoadingIndication(){
        playerLoadingIndicationTask.cancel()
        playerLoadingIndicationTask = Task{
            try await Task.sleep(for:.seconds(3))
            addPulsatingAnimation()
        }
    }
    
    @objc func animateButtonDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
    }

    // Animation function (bounce back)
    @objc func animateButtonUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 2.0,
                       options: [],
                       animations: {
            sender.transform = .identity
        })
    }
    
    private func addPulsatingAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.72
        pulseAnimation.duration = 0.8
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity

        progressBar.layer.add(pulseAnimation, forKey: "pulsing")
    }

    private func removePulsatingAnimation() {
        playerLoadingIndicationTask.cancel()
        progressBar.layer.removeAnimation(forKey: "pulsing")
    }
}
