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
    //State is usually one-time assigned property,
    //but it can be reassibgned in case of moving through video player subsequence
    private var state: SequenceState?

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
    
    /*
     0 for setting up container;
     1 for displaying single item;
     2 for displaying a sequence
     */
    private let playbackType: Int8
    private let item: MediaItem?
    private let container: MediaContainer?
    private let colorScheme: MediaTypeColorScheme?
    var onDismissAction: (String)->Void = {_ in }
    
    /*
     For setting up media display sequence, without actual displaying;
     it uses Container to create SequenceState
     */
    init(_ container: MediaContainer){
        fatalError()
        playbackType = 0
        self.container = container
        self.item = nil
        self.colorScheme = nil
        self.state = nil
        super.init(nibName: nil, bundle: nil)
    }

    //For displaying one item, video or photo;
    //Also setting up a SequenceState object
    init(_ item: MediaItem) {
        playbackType = 0
        self.item = item
        self.colorScheme = item.containerType.colorScheme
        self.container = nil
        self.state = SequenceState(item: item)
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
            Native().sl.i(msg: "VC created to display a container: \(container!.name)")
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
        super.viewWillDisappear(animated)
        player?.pause()
        
        guard playbackType==0, let link = (self.player?.currentItem?.asset as? AVURLAsset)?.url.absoluteString else { return }
        self.onDismissAction(link)
    }
        
    private func setPagerVC(){
        guard let sequenceState = state, playbackType == 0 else {return}
        
        let produced: PlayerViewController =
        if item != nil{
            sequenceState[item!]
        }
        else if container != nil{
            sequenceState[container!]
        }
        else {
            fatalError("Provide either an item or a container")
        }
        
        self.setViewControllers([produced], direction: .forward, animated: false)
    }

    private func setupPlayback(){
        switch playbackType{
        case 1:
            setupSingleItemPlayback()
        default:
            return
        }
        
//        switch playbackType{
//        case 0:
//            setupMixedPlayback()
//        case 1:
//            setupPlayer()
//            setupControlViews()
//            setupControlsHide()
////            setupQueuePlayer{
////                self.setupControlViews()
////                self.setupControlsHide()
////            }
//        default:
//            return
//        }
    }
}


extension PlayerViewController {
    
    //MARK: setup views
    
    private func setupControlViews(){
        guard let cS = colorScheme, let sequenceState = state else {return}
        
        //Controls container
        controlsContainerView.alpha = sequenceState.isCurrentPhoto ? 0 : 1
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
        controlsContainerView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 20)
        ])
        
        //loading indicator
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.color = cS.surface.uiColorLight()
        controlsContainerView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 45),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 45)
        ])
        
        if sequenceState.isCurrentPhoto {return}
        
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
        let config = UIImage.SymbolConfiguration(pointSize: 35, weight: .semibold)
        playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playConfig), for: .normal)
        playButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: playConfig), for: .highlighted)
        
        playButton.tintColor = playbackButtonsColor
        playButton.addTarget(self, action: #selector(animateButtonDown(_:)), for: .touchDown)
        playButton.addTarget(self, action: #selector(togglePlayPause), for: [.touchUpInside, .touchUpOutside])
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        controlsContainerView.addSubview(playButton)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
        ])
    }
    
    //MARK: setup player
    
    private func setupSingleItemPlayback(){
        dataSource = nil
        guard let sequenceState = state else {return}
        let item = sequenceState.itemsStore[sequenceState.pointer]
        
        switch item.contentType{
        case .photo:
            setupImage()
        case .video:
            setupVideo()
        default:
            Native().sl.s(msg: "unknown type for item: \(item.name)")
        }
        
        setupControlViews()
        setupControlsHide()
        
        func setupImage(){
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
        
        func setupVideo(){
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
            
            player?.play()
        }
    }
    
    private func setupPlayer() {
        guard let url = URL(string: item!.resolvedContentLink), (item != nil) else {
            Native().sl.s(msg: "Invalid URL: \(item!.resolvedContentLink)")
            return
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
            let firstItem = container!.mediaItems[index] as! MediaItem
            Native().sl.i(msg: "setting up player for item: \(firstItem.name)")
            if firstItem.contentType==MediaItemContentType.photo{
                setupMixedPlayback()
                return
            }
            
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
    
    private func setupMixedPlayback(){
        let index = Int(container!.itemPointer)
        let item = container!.mediaItems[index] as! MediaItem

        let modifier = AnyModifier { request in
            var r = request
            guard let key = item.headers.keys.first, let val = item.headers[key] else {return r}
            r.setValue(val, forHTTPHeaderField: key)
            
            return r
        }
        
        contentImageView.kf.setImage(
            with: URL(string: item.resolvedContentLink),
            options: [
                .cacheOriginalImage,
                .transition(.fade(0.2)),
                .scaleFactor(1.0),
                .requestModifier(modifier),
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
}

extension PlayerViewController{
    
    //MARK: add/remove observers
    
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
    
    private func observeNewItem(_ item: AVPlayerItem?) {
        if let currentItem = currentItem {
            currentItem.removeObserver(self, forKeyPath: "status")
        }
        
        currentItem = item
        currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
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
//        animateButtonUp(previousButton)
        
        player?.seek(to: CMTime(seconds: 0, preferredTimescale: 600))
        progressBar.setProgress(0.0, animated: false)
        blockPlayerProgressSet = true
        setupProgressSetRelease()
    }

    @objc private func skipForward() {
        setupControlsHide()
//        animateButtonUp(nextButton)
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
        if (playbackType==1){
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
            self.progressBar.alpha = isHidden ? 1 : 0
        }, completion: {_ in
            if isHidden {
                self.controlsHidden = false
                self.setupControlsHide()
            } else {
                self.controlsHidden = true
            }
        })
    }

    private func setupControlsHide(){
        guard !controlsHidden else {return}
        
        playerControlsHideTask.cancel()
        playerControlsHideTask = Task{
            try await Task.sleep(for:.seconds(5))
            UIView.animate(withDuration: 0.25, animations: {
                self.controlsContainerView.alpha = 0
                self.gradientView.alpha = 0
                self.progressBar.alpha = 0
            }, completion: { _ in
                self.controlsHidden = true
            })
        }
    }
    
    private func setupLoadingIndicatorActivation(){
        guard loadingIndicator.isHidden else {return}
        
        playerLoadingIndicationTask.cancel()
        playerLoadingIndicationTask = Task{
            try await Task.sleep(for: .seconds(4))
            if !controlsHidden{
                UIView.animate(withDuration: 0.15, animations: {
                    self.playButton.alpha = 0
                }, completion: { _ in
                    self.loadingIndicator.startAnimating()
                })
            } else {
                self.loadingIndicator.startAnimating()
                self.playButton.alpha = 0
            }
        }
    }
    
    private func deactivateLoadingIndicator(){
        playerLoadingIndicationTask.cancel()
        if !controlsHidden{
            UIView.animate(withDuration: 0.15, animations: {
                self.playButton.alpha = 1
            }, completion: { _ in
                self.loadingIndicator.stopAnimating()
            })
        } else {
            self.loadingIndicator.stopAnimating()
            self.playButton.alpha = 1
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
}

extension PlayerViewController {
    /*
     When we need to swipe to next/previous item:
     - Call either the 'item' or the 'container' VC's constructor from the outside
     - During initialization, create a new state and hold the reference
     both item and container can generate a universal state
     - On viewDidLoad(), produce a new controller, using subscript, and pass it to PagerVC
     - Newly created controller holds a pre-defined State reference,
     and ready for displaying items
     
     1. Depending on which subsequence (video or photo) is entered,
     retrieve new controller for photo, or video items array, if needed
     2. Every item change (photo or video) should be suplemented by the state transition
     */
    private struct SequenceState{
        let count: Int
        let pointer: Int
        
        let itemsStore: [MediaItem]
        
        //For internal use only
        private var currentItem: MediaItem {
            itemsStore[pointer]
        }
        var isCurrentPhoto: Bool {
            currentItem.contentType == .photo
        }
        var isCurrentVideo: Bool {
            currentItem.contentType == .video
        }
        
        private init(count: Int, pointer: Int, itemsStore: [MediaItem]) {
            self.count = count
            self.pointer = pointer
            self.itemsStore = itemsStore
        }
        
        init(item: MediaItem){
            self.count = 1
            self.pointer = 0
            self.itemsStore = [item]
        }
        init(container: MediaContainer){
            self.count = container.mediaItems.count
            self.pointer = Int(container.itemPointer)
            self.itemsStore = container.mediaItems as! [MediaItem]
        }
        
        subscript(_ currentState: SequenceState, container: MediaContainer, directionUp: Bool)-> SequenceState?{
            guard
                currentState.pointer>0 && !directionUp,
                currentState.pointer<count && directionUp
            else {return nil}
            
            return SequenceState(count: currentState.count, pointer: currentState.pointer + (directionUp ? 1 : -1), itemsStore: container.mediaItems as! [MediaItem])
        }
        
        subscript(_ item: MediaItem)-> PlayerViewController{
            PlayerViewController(state: self, item: item, container: nil)
        }
        subscript(_ container: MediaContainer)-> PlayerViewController{
            PlayerViewController(state: self, item: nil, container: container)
        }
        
        subscript()-> Task<[AVPlayerItem], Never>?{
            guard self.isCurrentVideo else {
                Native().sl.s(msg: "cannot generate player items sequence for photo")
                return nil
            }
            
            return Task<[AVPlayerItem], Never>.detached {
                let firstItem = itemsStore[pointer]
                Native().sl.i(msg: "setting up player for item: \(firstItem.name)")
                
                var mediaQueue = itemsStore
                if pointer>0{
                    mediaQueue.removeSubrange(0..<pointer)
                }
                let playerItems: [AVPlayerItem] = mediaQueue.map { item in
                    guard let url = URL(string: item.resolvedContentLink) else {
                        fatalError("Invalid URL")
                    }
                    
                    let assetOptions: [String: Any] = [
                        "AVURLAssetHTTPHeaderFieldsKey": item.headers
                    ]
                    
                    let asset = AVURLAsset(url: url, options: assetOptions)
                    return AVPlayerItem(asset: asset)
                }
                return playerItems
            }
        }
    }
}
    
extension PlayerViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let playerVC = viewController as? PlayerViewController,
              let state = playerVC.state,
              let item = playerVC.item
        else {return nil}
        return state[item]
//        let index = (viewControllers?.first as? PlayerViewController)?.index ?? 0
//        return index > 0 ? viewController(for: index - 1) : nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let playerVC = viewController as? PlayerViewController,
              let state = playerVC.state,
              let item = playerVC.item
        else {return nil}
        return state[item]
//        let index = (viewControllers?.first as? PlayerViewController)?.index ?? 0
//        return index < images.count - 1 ? viewController(for: index + 1) : nil
    }
}

//extension PlayerViewController: UIPageViewControllerDataSource{
//    
//}
