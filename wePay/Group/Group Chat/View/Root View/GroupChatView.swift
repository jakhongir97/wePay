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
    
}
