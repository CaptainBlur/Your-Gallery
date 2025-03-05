//
//  MCCollectionViewCell.swift
//  iosApp
//
//  Created by Valdo on 04.03.2025.
//

import UIKit
import shared

class MediaContainerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    var tapAction: ()->Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true // Ensure interactions are enabled
    }

    @objc private func cellTapped() {
        animateTap()
        tapAction()
    }
    private func animateTap() {
        UIView.animate(withDuration: 0.1, animations: {
           self.contentView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98) // Shrink effect
        },
        completion: { _ in
           UIView.animate(withDuration: 0.1) {
               self.contentView.transform = CGAffineTransform.identity // Restore size
           }
        })
        
//        UIView.animate(withDuration: 0.1, animations: {
//            self.contentView.alpha = 0.9 // Fade out effect
//        }, completion: { _ in
//            UIView.animate(withDuration: 0.1) {
//                self.contentView.alpha = 1.0 // Restore alpha
//            }
//        })
    }
}

extension MediaContainerCollectionViewCell{
}
