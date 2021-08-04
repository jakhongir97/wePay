//
//  UsersView.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

final class UsersView: CustomView {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet {
            collectionView.register(UINib(nibName: UsersCollectionViewCell.defaultReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: UsersCollectionViewCell.defaultReuseIdentifier)
            collectionView.allowsMultipleSelection = true
        }
    }
    
}
