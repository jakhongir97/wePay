//
//  GroupChatView.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

final class GroupChatView: CustomView {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet {
            collectionView.register(UINib(nibName: GroupChatCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: GroupChatCollectionViewCell.defaultReuseIdentifier)
        }
    }
    @IBOutlet weak var bottomView: UIView!{
        didSet {
            
        }
    }
    @IBOutlet weak var textField: UITextField!{
        didSet {
            textField.setLeftPaddingPoints(16)
        }
    }
    @IBOutlet weak var payButton: UIButton!
    
}
