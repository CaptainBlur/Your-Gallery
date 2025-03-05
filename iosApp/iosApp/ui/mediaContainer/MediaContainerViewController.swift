//
//  MediaContainerViewController.swift
//  iosApp
//
//  Created by Valdo on 04.03.2025.
//

import UIKit
import AVKit
import shared

class MediaContainerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private let mediaContainer: MediaContainer
    private let colorScheme: MediaTypeColorScheme
    
    init(_ mc: MediaContainer){
        mediaContainer = mc
        colorScheme = mc.containerType.colorScheme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        view.backgroundColor = colorScheme.surface.uiColor()
        setupCollectionView()

        
        self.modalPresentationStyle = UIModalPresentationStyle.automatic
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.setNeedsDisplay()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

}

extension MediaContainerViewController {
    
    override func viewWillLayoutSubviews(){
        let cellsPerRow = 2
        
        //The proper bounds of CollectionView are not set up at first
        collectionView.frame = view.bounds
        collectionView.collectionViewLayout.invalidateLayout()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let marginsAndInsets = layout.sectionInset.left + layout.sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + layout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            let stackViewVerticalInsets = CGFloat(20)
            let nameLabelMaxHeight = CGFloat(41)
            let sizeLabelMaxHeight = CGFloat(18)
            
//            Native().sl.i(obj: view.bounds.size)
//            Native().sl.f(obj: collectionView.bounds.size)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
            layout.itemSize =  CGSize(width: itemWidth, height: itemWidth + stackViewVerticalInsets + nameLabelMaxHeight + sizeLabelMaxHeight)
//            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            
//            Native().sl.fr(obj: layout.itemSize)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaContainer.mediaItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! MediaContainerCollectionViewCell
        setupViewCell(cell, indexPath.item)
//        Native().sl.w(obj: indexPath.item)
        return cell
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        collectionView?.collectionViewLayout.invalidateLayout()

    }

}

extension MediaContainerViewController {
    private func setupViewCell(_ cell: MediaContainerCollectionViewCell, _ index: Int){
        cell.layer.cornerRadius = 14
        cell.layer.borderWidth = 2
        //medium for videos, regular for photos
        cell.layer.borderColor = colorScheme.secondaryContainer_medium.uiColor().cgColor
        
//        cell.backgroundColor = colorScheme.surfaceDim.uiColor()
        cell.nameLabel.textColor = colorScheme.onSurface.uiColor()
        cell.sizeLabel.textColor = colorScheme.onSurfaceVariant.uiColor()
        
        
        let item: MediaItem = mediaContainer.mediaItems[index] as! MediaItem
        cell.nameLabel.text = item.name
        cell.sizeLabel.text = item.size
        cell.imageView.kf.setImage(
            with: URL(string: item.resolvedThumbnailLink),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
        cell.tapAction = {
//            self.present(ViewController(), animated: true, completion: nil)
//            self.launchPlayer(videoUrl: item.resolvedContentLink, headers: item.headers)
            
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
            let player = AVPlayer(playerItem: playerItem)
            
            let avController = AVPlayerViewController()
            avController.player = player
            self.present(avController, animated: true, completion: nil)
        }
    }
    
    private func setupCollectionView(){
        collectionView.backgroundColor = mediaContainer.containerType.colorScheme.surface.uiColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let spacing: CGFloat = 10
            
            layout.minimumInteritemSpacing = spacing
            layout.minimumLineSpacing = spacing
            layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        }

        collectionView.contentInsetAdjustmentBehavior = .never
        let nib = UINib(nibName: "MCCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CustomCell")
    }
}
