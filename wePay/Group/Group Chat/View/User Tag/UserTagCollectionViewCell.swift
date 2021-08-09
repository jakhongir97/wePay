//
//  UserTagCollectionViewCell.swift
//  wePay
//
//  Created by Admin NBU on 09/08/21.
//

import UIKit

class UserTagCollectionViewCell: UICollectionViewCell {
    // MARK: - Attributes
    @IBOutlet weak var imageView: UIImageView!{
        didSet {
            imageView.tintColor = UIColor.appColor(.gray)
        }
    }
    
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
