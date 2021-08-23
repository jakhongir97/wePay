//
//  TaggedUsersCollectionViewCell.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

class TaggedUsersCollectionViewCell: UICollectionViewCell {
    // MARK: - Attributes
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!

    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var isTicked = false {
        didSet {
            imageView.image = isTicked ? UIImage(systemSymbol: .largecircleFillCircle) : UIImage(systemSymbol: .circle)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isTicked = false
        imageView.image = UIImage(systemSymbol: .circle)
    }
}
