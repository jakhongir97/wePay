//
//  TaggedUsersDataProvider.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

final class TaggedUsersDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaggedUsersCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? TaggedUsersCollectionViewCell else { return UICollectionViewCell() }
        cell.prepareForReuse()
        if let firstName = items[indexPath.row].firstName , let lastName = items[indexPath.row].lastName {
            cell.label.text = firstName + " " + lastName
        }
        if let isMember = items[indexPath.row].isMember {
            cell.isTicked = isMember
        }
        return cell
    }
    
    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32.0, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        items[indexPath.row].isMember?.toggle()
        guard let vc = viewController as? TaggedUsersViewController else { return }
        vc.updatedTaggedUsers = items.filter({$0.isMember ?? true })
    }
    
}
