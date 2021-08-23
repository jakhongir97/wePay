//
//  GroupView.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

final class GroupView: CustomView {
    // MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: GroupCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: GroupCollectionViewCell.defaultReuseIdentifier)
        }
    }
}
