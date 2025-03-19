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
        contentView.isUserInteractionEnabled = true
    }

    @objc private func cellTapped() {
        animateTap()
    }
    private func animateTap() {
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
           self?.contentView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98) // Shrink effect
        },
        completion: {[weak self] _ in
            UIView.animate(withDuration: 0.1, animations: {
               self?.contentView.transform = CGAffineTransform.identity // Restore size
           }, completion: {[weak self] _ in
               self?.tapAction()
           })
        })
    }
    
    func animateHighlight(){
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.contentView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: { [weak self] _ in
            UIView.animate(withDuration: 0.25, animations: {
                self?.contentView.transform = CGAffineTransform.identity // Restore size
            })
        })
    }
}
