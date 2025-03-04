//
//  MediaContainerViewController.swift
//  iosApp
//
//  Created by Valdo on 04.03.2025.
//

import UIKit
import shared

class MediaContainerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        setupCollectionView()
        
        self.modalPresentationStyle = UIModalPresentationStyle.automatic
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MediaContainerViewController {
    private func setupCollectionView(){
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
    
    override func viewWillLayoutSubviews(){
        let cellsPerRow = 2
        
        //The proper bounds of CollectionView are not set up at first
        collectionView.frame = view.bounds
        collectionView.collectionViewLayout.invalidateLayout()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let marginsAndInsets = layout.sectionInset.left + layout.sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + layout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            
//            Native().sl.i(obj: view.bounds.size)
//            Native().sl.f(obj: collectionView.bounds.size)
            let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
            layout.itemSize =  CGSize(width: itemWidth, height: itemWidth + 150)
//            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            
//            Native().sl.fr(obj: layout.itemSize)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! MediaContainerCollectionViewCell
//        Native().sl.w(obj: cell.bounds.size)
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
