//
//  MediaContainerViewController.swift
//  iosApp
//
//  Created by Valdo on 04.03.2025.
//

import UIKit
import AVKit
import shared
import Kingfisher

class MediaContainerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    private let mediaContainer: MediaContainer
    private let colorScheme: MediaTypeColorScheme
    private let playersCache = PlayerVCCache()
    
    private var collectionView: UICollectionView!
    private var isCollectionViewSetup = false
    private var lastPlayedItem = LastPlayedItem()
    
    init(_ mc: MediaContainer){
        mediaContainer = mc
        colorScheme = mc.containerType.colorScheme
        super.init(nibName: "MediaContainerViewController", bundle: nil)
        
        lastPlayedItem.triggerAutoscroll = { [weak self] in
            self?.findAndMarkLastPlayedItem()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        setupLayout()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colorScheme.surfaceContainerLow.uiColor()
        setupCollectionView()
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}

extension MediaContainerViewController {
    
    private func setupCollectionView(){
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.contentInsetAdjustmentBehavior = .never
        let nib = UINib(nibName: "MCCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CustomCell")
    }
    
    private func setupLayout(){
        guard !isCollectionViewSetup,
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        
        let spacing: CGFloat = 10
        let navBarHeight = navigationController?.navigationBar.frame.height ?? 0
        
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: navBarHeight + spacing, left: spacing, bottom: spacing, right: spacing)
        
        isCollectionViewSetup = true
    }
    
    private func setupNavBar(){
        navigationItem.title = mediaContainer.name
        
        let standartAppearance = UINavigationBarAppearance()
        standartAppearance.configureWithTransparentBackground()
        standartAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : colorScheme.onSurface.uiColor(),
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .semibold)
        ]
        let edgeAppearance = standartAppearance.copy()
        
        switch mediaContainer.containerType{
        case .bunkr:
            edgeAppearance.backgroundColor = colorScheme.onPrimaryContainer.uiColor()
            standartAppearance.backgroundColor = colorScheme.secondaryContainer.uiColor().withAlphaComponent(0.65)
        case .pixeldrain:
            edgeAppearance.backgroundColor = colorScheme.secondaryContainer.uiColor()
            standartAppearance.backgroundColor = colorScheme.secondaryContainer.uiColor().withAlphaComponent(0.65)
        default:
            Void()
        }

        standartAppearance.backgroundEffect = UIBlurEffect(style: .light)

        navigationController?.navigationBar.standardAppearance = standartAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = edgeAppearance
        navigationController?.navigationBar.tintColor = colorScheme.primary.uiColor()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(onBackTap))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(onSaveTap))
    }
    
    @objc private func onBackTap(){
        self.dismiss(animated: true)
    }
    @objc private func onSaveTap(){
        
    }
    
    private func setupViewCell(_ cell: MediaContainerCollectionViewCell, _ index: Int){
        cell.layer.cornerRadius = 14
        cell.layer.borderWidth = 2
        
//        cell.backgroundColor = colorScheme.surfaceDim.uiColor()
        cell.nameLabel.textColor = colorScheme.onSurface.uiColor()
        cell.sizeLabel.textColor = colorScheme.onSurfaceVariant.uiColor()
        
        guard !mediaContainer.mediaItems.isEmpty else {
            Native.shared.sl.w(msg: "media items list is empty")
            return
        }
        guard let item: MediaItem = mediaContainer.mediaItems[index] as? MediaItem else {
            Native.shared.sl.w(msg: "media item is empty: \(index)")
            
            cell.nameLabel.text = "N/A"
            cell.sizeLabel.text = "N/A"
            
            return
        }
        
        cell.layer.borderColor = item.contentType==MediaItemContentType.video ?
        colorScheme.tertiaryContainer.uiColor().withAlphaComponent(0.5).cgColor :
        colorScheme.secondaryContainer.uiColor().cgColor
        
        cell.nameLabel.text = item.name
        cell.sizeLabel.text = item.size
        let modifier = AnyModifier { request in
            var r = request
            guard let key = item.headers.keys.first, let val = item.headers[key] else {return r}
            r.setValue(val, forHTTPHeaderField: key)
            
            return r
        }
        
        cell.imageView.kf.setImage(
            with: URL(string: item.resolvedThumbnailLink),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage,
                .requestModifier(modifier)
            ]
        )
        cell.tapAction = { [weak self] in
            guard self != nil else { return }
            self!.mediaContainer.itemPointer = Int32(index)
            let playerController = PlayerViewController(self!.mediaContainer, controllersCache: self!.playersCache, lastPlayedItem: self!.lastPlayedItem)
            
            self!.present(playerController, animated: true)
        }
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
            
//            Native.shared.sl.i(obj: view.bounds.size)
//            Native.shared.sl.f(obj: collectionView.bounds.size)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
            layout.itemSize =  CGSize(width: itemWidth, height: itemWidth + stackViewVerticalInsets + nameLabelMaxHeight + sizeLabelMaxHeight)
//            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            
//            Native.shared.sl.fr(obj: layout.itemSize)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaContainer.mediaItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! MediaContainerCollectionViewCell
        setupViewCell(cell, indexPath.item)
//        Native.shared.sl.w(obj: indexPath.item)
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

extension MediaContainerViewController: UIScrollViewDelegate{
    private func findAndMarkLastPlayedItem(){
        guard self.lastPlayedItem.index != -1 else {return}
        let lastPlayedItemIndexPath = IndexPath(item: lastPlayedItem.index, section: 0)
        let cell = collectionView.cellForItem(at: lastPlayedItemIndexPath)
        if collectionView.visibleCells.contains(where: {
            $0 == cell
        }){
            (cell as! MediaContainerCollectionViewCell).animateHighlight()
        }
        else{
            Task{
                collectionView.scrollToItem(at: lastPlayedItemIndexPath, at: .centeredVertically, animated: true)
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView){
        guard lastPlayedItem.index != -1 else {return}
        let lastPlayedItemIndexPath = IndexPath(item: lastPlayedItem.index, section: 0)
        let cell = collectionView.cellForItem(at: lastPlayedItemIndexPath)
        (cell as? MediaContainerCollectionViewCell)?.animateHighlight()
        lastPlayedItem.index = -1
    }

    class LastPlayedItem{
        var index: Int = -1
        var triggerAutoscroll: ()-> Void = {}
    }
}


