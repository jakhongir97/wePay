//
//  TaggedUsersView.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

final class TaggedUsersView: CustomView {
    // MARK: - Outlets
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: TaggedUsersCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: TaggedUsersCollectionViewCell.defaultReuseIdentifier)
            collectionView.allowsMultipleSelection = true
        }
    }
}
