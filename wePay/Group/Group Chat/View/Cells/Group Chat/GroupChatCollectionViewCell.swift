//
//  GroupChatCollectionViewCell.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

class GroupChatCollectionViewCell: UICollectionViewCell {
    // MARK: - Attributes
    @IBOutlet var messageLabel: LabelWithPadding! {
        didSet {
            messageLabel.backgroundColor = UIColor.appColor(.blueOpacity)
            messageLabel.layer.cornerRadius = 20
            messageLabel.layer.cornerCurve = .continuous
            messageLabel.clipsToBounds = true
        }
    }
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var usersCollectionView: UICollectionView! {
        didSet {
            usersCollectionView.register(UINib(nibName: UserTagCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: UserTagCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet var checkImageView: UIImageView! {
        didSet {
            checkImageView.tintColor = UIColor.appColor(.blueOpacity)
        }
    }

    internal var userTagsDataProvider: UserTagsDataProvider?
    internal var viewController: GroupChatViewController?

    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let userTagsDataProvider = UserTagsDataProvider(viewController: viewController)
        userTagsDataProvider.collectionView = usersCollectionView
        self.userTagsDataProvider = userTagsDataProvider
    }
}
