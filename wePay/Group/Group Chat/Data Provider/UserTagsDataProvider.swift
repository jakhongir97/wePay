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
        cell.prepareForReuse()
        if let isPaid = items[indexPath.row].isPaid {
            cell.checkImageView.isHidden = !isPaid
        }

        if let vc = viewController as? GroupChatViewController {
            cell.imageView.tintColor = vc.viewModel.returnUserID() == items[indexPath.row].userID ? UIColor.appColor(.blueOpacity) : UIColor.appColor(.gray).withAlphaComponent(0.5)
        }
        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
}
