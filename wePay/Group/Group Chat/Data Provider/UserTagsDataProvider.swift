//
//  UserTagsDataProvider.swift
//  wePay
//
//  Created by Admin NBU on 09/08/21.
//

import UIKit

final class UserTagsDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    // MARK: - Attributes
    weak var viewController: UIViewController?
    
    internal var items = [User]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    // MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserTagCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? UserTagCollectionViewCell else { return UICollectionViewCell() }
        cell.imageView.image = UIImage(systemSymbol: .personCropCircleFill)
        return cell
    }
    
    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height*3/4, height: collectionView.frame.height*3/4)
    }
}
