//
//  UserTagCollectionViewCell.swift
//  wePay
//
//  Created by Admin NBU on 09/08/21.
//

import UIKit

class UserTagCollectionViewCell: UICollectionViewCell {
    // MARK: - Attributes
    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.image = UIImage(systemSymbol: .personCropCircleFill)
            imageView.tintColor = UIColor.appColor(.gray)
        }
    }
    @IBOutlet var checkImageView: UIImageView! {
        didSet {
            checkImageView.tintColor = UIColor.appColor(.green)
        }
    }

    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(systemSymbol: .personCropCircleFill)
    }
}
