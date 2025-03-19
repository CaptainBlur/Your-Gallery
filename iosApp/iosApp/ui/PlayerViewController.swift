//
//  PlayerViewController.swift
//  iosApp
//
//  Created by Valdo on 05.03.2025.
//

import UIKit
import AVFoundation
import shared
import Kingfisher

class PlayerViewController: UIPageViewController {
    private var state: SequenceState

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var contentImageView: UIImageView = UIImageView()
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
    private let closeButton = UIButton()
    private let unablePlayImage = UIImageView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private var playerProgressSetTask: Task<Void, Error> = Task(){}
    private var playerControlsHideTask: Task<Void, Error> = Task(){}
    private var playerLoadingIndicationTask: Task<Void, Error> = Task(){}
    private var controlsHidden = false
    private var timeCounterAnimated = false
    
    /*
     0 for setting up container;
     1 for displaying single item;
     2 for displaying a sequence
     */
    private let playbackType: Int8
    private let item: MediaItem?
    private let container: MediaContainer?
    private let colorScheme: MediaTypeColorScheme?
    var onPlaybackControllerDismiss: (Int)->Void = {_ in }
    var onStartupControllerDismiss: ()-> Void = {}
    
    /*
     For setting up media display sequence, without actual displaying;
     it uses Container to create SequenceState
     */
    init(_ container: MediaContainer, controllersCache selfCache: PlayerVCCache = PlayerVCCache(), lastPlayedItem: MediaContainerViewController.LastPlayedItem){
        playbackType = 0
        self.container = container
        self.item = nil
        self.colorScheme = container.containerType.colorScheme
        self.state = SequenceState(container: container, selfCache: selfCache, lastPlayedItem: lastPlayedItem)
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    //For displaying one item, video or photo;
    //Also setting up a SequenceState object
    init(_ item: MediaItem, controllersCache selfCache: PlayerVCCache = PlayerVCCache()) {
        playbackType = 0
        self.item = item
        self.colorScheme = item.containerType.colorScheme
        self.container = nil
        self.state = SequenceState(item: item, selfCache: selfCache)
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    private init(state: SequenceState, item: MediaItem?, container: MediaContainer?){
        self.state = state
        self.item = item
        self.container = container
        
        if item != nil{
            self.playbackType = 1
            self.colorScheme = item!.containerType.colorScheme
            Native().sl.i(msg: "VC created to display an item: \(item!.name)")
        } else if container != nil {
            self.playbackType = 2
            self.colorScheme = container!.containerType.colorScheme
            Native().sl.i(msg: "VC created to display a container: \(state.itemsStore[state.pointer]?.name ?? "nil")")
        } else {
            fatalError("Provide either an item or a container")
        }
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        dataSource = self
        
        setPagerVC()
        setupPlayback()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
        gradientView.layer.sublayers?.first?.frame = gradientView.bounds
    }

    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        togglePlayPause(true)
        
        if playbackType == 0{
            state.lastPlayedItem?.triggerAutoscroll()
        }
        
        if playbackType==2{
            state.lastPlayedItem?.index = state.pointer
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        if state.isCurrentVideo {
            instantShowControls()
        }
    }
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
//        Native().sl.i(obj: state?.pointer)
        togglePlayPause(false)
    }
        
    private func setPagerVC() {
        guard playbackType == 0 else { return }

        let produced: PlayerViewController = item != nil ? state[item!] : state[container!]

        if let currentVC = viewControllers?.first, currentVC == produced {
            Native().sl.w(msg: "setViewControllers skipped: Already on this page")
            return
        }

        self.setViewControllers([produced], direction: .forward, animated: false)
    }


    private func setupPlayback(){
        switch playbackType{
        case 1, 2:
//            setupTestImage()
            setupSingleItemPlayback()
        default:
            return
        }
    }
}


extension PlayerViewController {
    
    //MARK: setup views
    
    private func setupTestImage(){
        contentImageView.kf.setImage(
            with: URL(string: "https://img10.reactor.cc/pics/post/full/David-Dubnitskiy-%28photographer%29-Anastasiia-Galliard-%D0%B3%D1%80%D1%83%D0%B4%D1%8C-%D0%AD%D1%80%D0%BE%D1%82%D0%B8%D0%BA%D0%B0-8830844.jpeg"),
            options: [
                .cacheOriginalImage,
                .transition(.fade(0.2)),
                .scaleFactor(1.0),
//                .requestModifier(modifier),
            ],
            completionHandler: { result in
                if case .failure(let error) = result {
                    Native().sl.w(msg: "Image Loading Failed: \(error.localizedDescription)")
                }
            }
        )
        contentImageView.contentMode = .scaleAspectFit
        contentImageView.clipsToBounds = true
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentImageView)
        
        NSLayoutConstraint.activate([
            contentImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentImageView.topAnchor.constraint(equalTo: view.topAnchor),
            contentImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupControlViews(){
        guard let cS = colorScheme else {return}
        controlsHidden = state.isCurrentPhoto ? true : false
        
        //Controls container
        //the hell happens with gesture recognizers when it's hidden,
        //only god knows
        //try not to add this view and promptly you find out, the scroll is broken.
        //feels like apple's just breaking my balls
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
        
        //Close button
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)), for: .normal)
        
        closeButton.tintColor = cS.surface.uiColorLight()
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.alpha = state.isCurrentPhoto ? 0 : 1
        controlsContainerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 20)
        ])
        
        //Loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = cS.surface.uiColorLight()
        controlsContainerView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 45),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        if state.isCurrentPhoto {return}
        
        //Gradient view
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false
        view.addSubview(gradientView)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.65).cgColor,
            UIColor.clear.cgColor
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
            gradientView.heightAnchor.constraint(equalToConstant: 160)
        ])
        
        //Time counter
        timeCounterLabel.text = "--:--"
        timeCounterLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        timeCounterLabel.textColor = cS.surfaceContainerLowest.uiColorLight()
        timeCounterLabel.alpha = 0
        timeCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        controlsContainerView.addSubview(timeCounterLabel)
        
        //Progress bar
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.setProgress(0.0, animated: false)
        progressBar.trackTintColor = cS.surfaceContainerHigh.uiColor().withAlphaComponent(0.85)
        progressBar.progressTintColor = cS.tertiaryContainer_medium.uiColor().withAlphaComponent(0.95)
        view.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -20),
            progressBar.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -80),
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

        let progressPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleProgressSeekGesture(_:)))
        let progressTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProgressTap(_:)))

        seekAreaView.addGestureRecognizer(progressPanGesture)
        seekAreaView.addGestureRecognizer(progressTapGesture)
        progressTapGesture.require(toFail: progressPanGesture)
        
        //Unable to play image
        let symbolConfig = UIImage.SymbolConfiguration(hierarchicalColor: cS.surfaceContainerHigh.uiColorLight().withAlphaComponent(0.95))
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
        let playbackButtonsColor = cS.surfaceContainerHigh.uiColorLight().withAlphaComponent(0.88)
        let playConfig = UIImage.SymbolConfiguration(pointSize: 45, weight: .semibold)
        playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playConfig), for: .normal)
        playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playConfig), for: .highlighted)
        
        playButton.tintColor = playbackButtonsColor
        playButton.addTarget(self, action: #selector(animateButtonDown(_:)), for: .touchDown)
        playButton.addTarget(self, action: #selector(togglePlayPauseAction), for: [.touchUpInside, .touchUpOutside])
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        controlsContainerView.addSubview(playButton)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
        ])
    }
    
    //MARK: setup content display
    
    private func setupSingleItemPlayback(){
        guard let item = state.itemsStore[state.pointer] else {return}
        
        switch item.contentType{
        case .photo:
            setupImage(item)
        case .video:
            setupVideo(item)
        default:
            Native().sl.s(msg: "unknown type for item: \(item.name)")
        }
        
        setupControlViews()
        setupControlsHide()
        
    }
    
    private func setupImage(_ item: MediaItem){
        contentImageView.kf.setImage(
            with: URL(string: item.resolvedContentLink),
            options: [
                .cacheOriginalImage,
                .transition(.fade(0.2)),
                .scaleFactor(1.0),
                //                .requestModifier(modifier),
            ],
            completionHandler: { result in
                if case .failure(let error) = result {
                    Native().sl.w(msg: "Image Loading Failed: \(error.localizedDescription)")
                }
            }
        )
        contentImageView.contentMode = .scaleAspectFit
        contentImageView.clipsToBounds = true
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentImageView)
        
        NSLayoutConstraint.activate([
            contentImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentImageView.topAnchor.constraint(equalTo: view.topAnchor),
            contentImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupVideo(_ item: MediaItem){
        guard let url = URL(string: item.resolvedContentLink) else {
            Native().sl.s(msg: "Invalid URL: \(item.resolvedContentLink)")
            return
        }
        
//            Native().sl.i(msg: "setting up player for item: \(item.name)")

        // Set AVAsset HTTP headers
        let assetOptions: [String: Any] = [
            "AVURLAssetHTTPHeaderFieldsKey": item.headers
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
        
//        player?.play()
    }
    
}

extension PlayerViewController{
    
    //MARK: add/remove observers
    
    private func addObservers() {
        // Observe playback state
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .initial], context: nil)

        // Track video completion
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

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
                    deactivateLoadingIndicator()
//                    Native().sl.fr(msg: "▶️ Player")
                case .paused:
                    deactivateLoadingIndicator()
//                    Native().sl.fr(msg: "⏸️ Player")
                case .waitingToPlayAtSpecifiedRate:
                    setupLoadingIndicatorActivation()
//                    Native().sl.fr(msg: "⏳ Player")
                @unknown default:
                    Native().sl.fr(msg: "❓ Player")
                }
            }
        } else
        if keyPath == "status", let playerItem = object as? AVPlayerItem {
            switch playerItem.status {
            case .readyToPlay:
                Native().sl.fr(msg: "media successfully resolved")
                animateTimeCounter()
            case .failed:
                Native().sl.w(msg: "failed to load media: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                player?.pause()
                playButton.isHidden = true
                unablePlayImage.isHidden = false
                setupLoadingIndicatorActivation()
                resetTimeCounter()
                
                state.selfCache.clearCurrent(index: state.pointer)
            case .unknown:
                Native().sl.fr(msg: "playerItem status unknown")
            @unknown default:
                Native().sl.w(msg: "Unhandled AVPlayerItem status")
            }
        }
    }

    @objc private func handleProgressSeekGesture(_ gesture: UIPanGestureRecognizer) {
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
            showExtraProgressBar()
        case .changed:
            player.seek(to: newTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
            progressBar.progress = Float(newSeconds / durationSeconds)
        case .ended:
            setupProgressSetRelease()
            setupControlsHide()
            hideExtraProgressBar()
        default:
            break
        }
    }
    
    @objc private func handleProgressTap(_ gesture: UITapGestureRecognizer) {
        guard let player = player, let duration = player.currentItem?.duration else { return }
        if controlsHidden{
            handleTapGesture()
            return
        }
        
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
    
    private func removeObservers() {
        if playbackType==1{
            player?.currentItem?.removeObserver(self, forKeyPath: "status")
        }
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self)
        
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
        
        if playbackType==0, let currentItem = currentItem {
            currentItem.removeObserver(self, forKeyPath: "status")
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: touch gestures and animations
    
    private func togglePlayPause(_ pause: Bool) {
        animateButtonUp(playButton)
        
        guard let player = player else { return }
        let playConfig = UIImage.SymbolConfiguration(pointSize: 45, weight: .semibold)
        let playIcon = UIImage(systemName: "play.fill", withConfiguration: playConfig)
        let pauseIcon = UIImage(systemName: "pause.fill", withConfiguration: playConfig)

        if pause {
            player.pause()
            playButton.setImage(playIcon, for: .normal)
            playButton.setImage(playIcon, for: .highlighted)
        } else {
            if progressBar.progress == 0.0{
                player.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
            }
            player.play()
            playButton.setImage(pauseIcon, for: .normal)
            playButton.setImage(pauseIcon, for: .highlighted)
        }
        setupControlsHide()
    }
    
    @objc private func togglePlayPauseAction() {
        guard let player = player else { return }
        
        player.timeControlStatus == .playing ? togglePlayPause(true) : togglePlayPause(false)
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
        timeCounterAnimated = true
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
        resetPlayerPlaybackState()
    }
    
    private func resetPlayerPlaybackState(){
        progressBar.setProgress(0.0, animated: false)
        timeCounterLabel.text = "00:00"
        
        togglePlayPause(true)
    }
    
    private func advanceToNextItem(){
        
    }

    private func setupProgressSetRelease(){
        playerProgressSetTask.cancel()
        playerProgressSetTask = Task{
            try await Task.sleep(for:.seconds(2))
            blockPlayerProgressSet = false
        }
    }
    
    @objc private func handleTapGesture() {
        UIView.animate(withDuration: 0.25, animations: { [self] in
            closeButton.alpha = controlsHidden ? 1 : 0
            gradientView.alpha = controlsHidden ? 1 : 0
            progressBar.alpha = controlsHidden ? 1 : 0
            if timeCounterAnimated{
                timeCounterLabel.alpha = controlsHidden ? 1 : 0
            }
            if loadingIndicator.isAnimating{
                loadingIndicator.alpha = controlsHidden ? 1 : 0
            }else{
                playButton.alpha = controlsHidden ? 1 : 0
            }
        }, completion: { [self]_ in
            if controlsHidden {
                controlsHidden = false
                setupControlsHide()
            } else {
                controlsHidden = true
            }
        })
    }
    
    private func instantShowControls(){
        closeButton.alpha = 1
        if loadingIndicator.isAnimating{
            loadingIndicator.alpha = controlsHidden ? 1 : 0
        }else{
            playButton.alpha = controlsHidden ? 1 : 0
        }
        gradientView.alpha = 1
        progressBar.alpha = 1
        if timeCounterAnimated{
            timeCounterLabel.alpha = 1
        }
        
        controlsHidden = false
    }

    private func setupControlsHide(){
        guard !controlsHidden else {return}
        
        playerControlsHideTask.cancel()
        playerControlsHideTask = Task{
            try await Task.sleep(for:.seconds(5))
            UIView.animate(withDuration: 0.25, animations: { [self] in
                closeButton.alpha = 0
                playButton.alpha = 0
                loadingIndicator.alpha = 0
                gradientView.alpha = 0
                progressBar.alpha = 0
                if timeCounterAnimated{
                    timeCounterLabel.alpha = 0
                }
            }, completion: { _ in
                self.controlsHidden = true
            })
        }
    }
    
    private func setupLoadingIndicatorActivation(){
        guard loadingIndicator.isHidden else {return}
        guard unablePlayImage.isHidden else {playerLoadingIndicationTask.cancel(); return}
        
        playerLoadingIndicationTask.cancel()
        playerLoadingIndicationTask = Task{
            try await Task.sleep(for: .seconds(4))
            if !controlsHidden{
                UIView.animate(withDuration: 0.15, animations: {
                    self.playButton.alpha = 0
                }, completion: { _ in
                    self.loadingIndicator.alpha = 1
                    self.loadingIndicator.startAnimating()
                })
            } else {
                self.loadingIndicator.startAnimating()
            }
        }
    }
    
    private func deactivateLoadingIndicator(){
        playerLoadingIndicationTask.cancel()
        if !controlsHidden{
            UIView.animate(withDuration: 0.15, animations: {
                self.playButton.alpha = 1
            }, completion: { _ in
                self.loadingIndicator.alpha = 0
                self.loadingIndicator.stopAnimating()
            })
        } else {
            self.loadingIndicator.stopAnimating()
        }
    }
    
    private func showExtraProgressBar(){
        if controlsHidden {
            UIView.animate(withDuration: 0.2, animations: {
                self.progressBar.alpha = 1
            })
        }
    }
    
    private func hideExtraProgressBar(){
        if controlsHidden {
            UIView.animate(withDuration: 0.2, animations: {
                self.progressBar.alpha = 0
            })
        }
    }
    
    @objc func animateButtonDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
    }

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
}

extension PlayerViewController {
    /*
     1. Represents a replicable state for pages in PageViewController
     2. Every new controller should be issued from a newly created object of this type
     
     - Call either the 'item' or the 'container' VC's constructor from the outside
     - During initialization, create a new state and hold the reference;
     state may be suplemented by both item and container
     - On viewDidLoad(), produce a new controller, using subscript, and pass it to PagerVC
     - Newly created controller holds a pre-defined State reference,
     and ready for displaying items
     */
    private struct SequenceState{
        let count: Int
        let pointer: Int
        let selfCache: PlayerVCCache
        let lastPlayedItem: MediaContainerViewController.LastPlayedItem?
        
        let itemsStore: [MediaItem?]
        
        //For internal use only
        private var currentItem: MediaItem? {
            itemsStore[pointer]
        }
        var isCurrentPhoto: Bool {
            currentItem?.contentType == .photo
        }
        var isCurrentVideo: Bool {
            currentItem?.contentType == .video
        }
        
        private init(count: Int, pointer: Int, itemsStore: [MediaItem], selfCache: PlayerVCCache, lastPlayedItem: MediaContainerViewController.LastPlayedItem?) {
            self.count = count
            self.pointer = pointer
            self.itemsStore = itemsStore
            self.selfCache = selfCache
            self.lastPlayedItem = lastPlayedItem
        }
        
        init(item: MediaItem, selfCache: PlayerVCCache){
            self.count = 1
            self.pointer = 0
            self.itemsStore = [item]
            self.selfCache = selfCache
            self.lastPlayedItem = nil
        }
        init(container: MediaContainer, selfCache: PlayerVCCache, lastPlayedItem: MediaContainerViewController.LastPlayedItem){
            self.count = container.mediaItems.count
            self.pointer = Int(container.itemPointer)
            self.itemsStore = container.mediaItems as? [MediaItem] ?? [nil]
            self.selfCache = selfCache
            self.lastPlayedItem = lastPlayedItem
        }
        
        //use this subscript to replicate the state
        subscript(container: MediaContainer, directionUp: Bool)-> SequenceState?{
            if (self.pointer==0 && !directionUp) || (self.pointer==self.count-1 && directionUp){ return nil}
            
            return SequenceState(count: self.count, pointer: self.pointer + (directionUp ? 1 : -1), itemsStore: container.mediaItems as! [MediaItem], selfCache: self.selfCache, lastPlayedItem: self.lastPlayedItem)
        }
        
        subscript(_ item: MediaItem)-> PlayerViewController{
            if let cachedController = selfCache[pointer]{
                return cachedController
            }
            else{
                let controller = PlayerViewController(state: self, item: item, container: nil)
                selfCache[(pointer, controller)]
                return controller
            }
        }
        subscript(_ container: MediaContainer)-> PlayerViewController{
            if let cachedController = selfCache[pointer]{
                return cachedController
            }
            else{
                let controller = PlayerViewController(state: self, item: nil, container: container)
                selfCache[(pointer, controller)]
                return controller
            }
        }
        subscript(oldController: PlayerViewController)-> PlayerViewController{
            if let cachedController = selfCache[pointer]{
                return cachedController
            }
            else{
                let controller = PlayerViewController(state: self, item: oldController.item, container: oldController.container)
                selfCache[(pointer, controller)]
                return controller
            }
        }
    }
}
    
extension PlayerViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let playerVC = viewController as? PlayerViewController,
              let container = playerVC.container,
              let newState = playerVC.state[container, false]
        else {return nil}
        return newState[playerVC]
//        guard let playerVC = viewController as? PlayerViewController,
//              let state = playerVC.state,
//              let item = playerVC.item
//        else {return nil}
//        return state[item]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let playerVC = viewController as? PlayerViewController,
              let container = playerVC.container,
              let newState = playerVC.state[container, true]
        else {return nil}
        return newState[playerVC]
        //        guard let playerVC = viewController as? PlayerViewController,
        //              let state = playerVC.state,
        //              let item = playerVC.item
        //        else {return nil}
        //        return state[item]
    }
    
}

class PlayerVCCache{
    var dict: [Int: PlayerViewController] = [:]
    private let cacheTolerance = 3
    
    subscript (index: Int)-> PlayerViewController?{
        clearCache(targetRetrieveIndex: index)
        
        if dict.keys.contains(where:{
            $0==index
        }){
            return dict[index]
        } else{
            return nil
        }
    }
    subscript (entry: (Int, PlayerViewController))-> Void{
        dict[entry.0] = entry.1
        return Void()
    }
    
    private func clearCache(targetRetrieveIndex index: Int){
        dict = dict.filter{ element in
            let range = index-cacheTolerance ... index+cacheTolerance
            return range.contains(element.key) ? true : false
        }
    }
    
    func clearCurrent(index: Int){
        dict[index] = nil
    }
}
