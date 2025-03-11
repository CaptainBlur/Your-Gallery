//
//  MediaContainerViewController.swift
//  iosApp
//
//  Created by Valdo on 04.03.2025.
//

import UIKit
import AVKit
import shared

class MediaContainerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    private let mediaContainer: MediaContainer
    private let colorScheme: MediaTypeColorScheme
    
    private var collectionView: UICollectionView!
    private var isCollectionViewSetup = false
    private var lastPlayedItemIndexPath: IndexPath? = nil
    
    init(_ mc: MediaContainer){
        mediaContainer = mc
        colorScheme = mc.containerType.colorScheme
        
        super.init(nibName: "MediaContainerViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        view.backgroundColor = colorScheme.surface.uiColor()
        setupCollectionView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        guard !mediaContainer.mediaItems.isEmpty else {
            Native().sl.w(msg: "media items list is empty")
            return
        }
        guard let item: MediaItem = mediaContainer.mediaItems[index] as? MediaItem else {
            Native().sl.w(msg: "media item is empty: \(index)")
            
            cell.nameLabel.text = "N/A"
            cell.sizeLabel.text = "N/A"
            
            return
        }
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
        cell.tapAction = { [weak self] in
            guard self != nil else { return }
            self!.mediaContainer.itemPointer = Int32(index)
            let playerController = PlayerViewController(self!.mediaContainer)
            playerController.onDismissAction = {[weak self] lastLink in
                self?.findAndMarkLastPlayedItem(link: lastLink)
            }
            self!.present(playerController, animated: true)
        }
    }
    
    private func setupCollectionView(){
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
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

extension MediaContainerViewController: UIScrollViewDelegate{
    private func findAndMarkLastPlayedItem(link: String){
        Task{
            let items = mediaContainer.mediaItems
            let item = items.filter{ item in
                (item as! MediaItem).resolvedContentLink == link
            }[0] as! MediaItem
            
            lastPlayedItemIndexPath = IndexPath(item: Int(item.index), section: 0)
            collectionView.scrollToItem(at: lastPlayedItemIndexPath!, at: .centeredVertically, animated: true)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView){
        guard let indexPath = lastPlayedItemIndexPath else {return}
        let cell = collectionView.cellForItem(at: indexPath)
        (cell as? MediaContainerCollectionViewCell)?.animateHighlight()
        lastPlayedItemIndexPath = nil
    }

}
