//
//  MCCollectionViewCell.swift
//  iosApp
//
//  Created by Valdo on 04.03.2025.
//

import UIKit
import shared

class MediaContainerCollectionViewCell: UICollectionViewCell {
    static let labelHeight: CGFloat = 20
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        setupSubviews()

    }
    
//    func configureCell(imageName: String) {
//        imageView.image = UIImage(named: imageName)
//    }

}

extension MediaContainerCollectionViewCell{
}
