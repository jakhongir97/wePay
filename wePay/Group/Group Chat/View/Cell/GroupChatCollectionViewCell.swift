//
//  GroupChatCollectionViewCell.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

class GroupChatCollectionViewCell: UICollectionViewCell {
    // MARK: - Attributes
    
    @IBOutlet weak var messageLabel: LabelWithPadding! {
        didSet {
            messageLabel.backgroundColor = UIColor.appColor(.blueOpacity)
            messageLabel.layer.cornerRadius = 20
            messageLabel.layer.cornerCurve = .continuous
            messageLabel.clipsToBounds = true
        }
    }
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
