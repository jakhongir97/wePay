//
//  GroupChatDataProvider.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

enum Curreny: String {
    case uz = "sum"
    case usa = "$"
}

final class GroupChatDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?

    internal var items = [Message]() {
        didSet {
            self.collectionView.reloadData()
            self.collectionView.scrollToLast()
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupChatCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? GroupChatCollectionViewCell else { return UICollectionViewCell() }
        cell.prepareForReuse()
        guard let vc = self.viewController as? GroupChatViewController else { return UICollectionViewCell() }
            cell.viewController = vc

        if let message = items[indexPath.row].message, let currency = items[indexPath.row].currency {
            cell.messageLabel.text = message.withCurreny(currency: currency)
        }
        if let timestamp = items[indexPath.row].timeStamp {
            cell.dateLabel.text = DateFormatter.string(timestamp: timestamp)
        }

        if let users = items[indexPath.row].taggedUsers {
            cell.userTagsDataProvider?.items = users
        }

        if let isPaid = items[indexPath.row].isPaid, let isCompleted = items[indexPath.row].isCompleted {
            if let owner = items[indexPath.row].owner, owner == vc.viewModel.returnUserID() {
                cell.checkImageView.image = UIImage()
                cell.profileImageView.tintColor = UIColor.appColor(.blueOpacity)
            } else {
                cell.profileImageView.tintColor = UIColor.appColor(.gray).withAlphaComponent(0.5)
                cell.checkImageView.tintColor = isPaid ? UIColor.appColor(.green) : UIColor.appColor(.red)
                cell.checkImageView.image = isPaid ? UIImage(systemSymbol: .checkmarkCircleFill) : UIImage(systemSymbol: .exclamationmarkCircleFill)
            }

            if isCompleted {
                cell.checkImageView.image = UIImage(systemSymbol: .checkmarkCircleFill)
                cell.checkImageView.tintColor = UIColor.appColor(.blueOpacity)
            }
        }

        if items[indexPath.row].isPaid == nil, let owner = items[indexPath.row].owner, owner != vc.viewModel.returnUserID() {
            cell.profileImageView.tintColor = UIColor.appColor(.gray).withAlphaComponent(0.5)
            cell.messageLabel.backgroundColor = UIColor.appColor(.gray).withAlphaComponent(0.5)
            cell.checkImageView.image = UIImage()
        }

        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20.0, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    // MARK: - Context Menu
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            return self.makeContextMenu(indexPath: indexPath)
        }
    }

    func makeContextMenu(indexPath: IndexPath) -> UIMenu {
        guard let vc = self.viewController as? GroupChatViewController else { return UIMenu() }
        guard let messageID = self.items[indexPath.row].id else { return UIMenu() }
        guard let groupID = vc.group?.id else { return UIMenu() }

        var payTitle = "Pay"
        var payImage = UIImage(systemSymbol: .creditcardFill)
        if let isPaid = items[indexPath.row].isPaid {
            payTitle = isPaid ? "You've already paid!" : "Pay   \(items[indexPath.row].average?.withCurreny(currency: items[indexPath.row].currency ?? "") ?? "")"
            payImage = isPaid ? UIImage(systemSymbol: .checkmarkCircleFill) : UIImage(systemSymbol: .creditcardFill)
        } else {
            payTitle = "You're not tagged!"
            payImage = UIImage(systemSymbol: .exclamationmarkCircleFill)
        }

        let pay = UIAction(title: payTitle, image: payImage) { _ in
            if let isPaid = self.items[indexPath.row].isPaid {
                if !isPaid {
                    vc.viewModel.payMessage(messageID: messageID, groupID: groupID, isPaid: true)
                }
            }
        }

        let format = UIAction(title: "Format", image: UIImage(systemSymbol: .dollarsignCircle)) { _ in
            vc.viewModel.changeCurrencyMessage(messageID: messageID)
        }

        let tag = UIAction(title: "Tag", image: UIImage(systemSymbol: .tag)) { _ in
            guard let groupUsers = vc.users else { return }
            vc.coordinator?.pushTaggedUsersVC(groupID: groupID, messageID: messageID, groupUsers: groupUsers)
        }

        let edit = UIAction(title: "Edit", image: UIImage(systemSymbol: .pencil)) { _ in
            vc.editMessage(messageID: messageID)
        }

        let delete = UIAction(title: "Delete", image: UIImage(systemSymbol: .trashFill), attributes: [.destructive]) { _ in
            vc.viewModel.deleteMessage(messageID: messageID, groupID: groupID)
        }

        if let owner = items[indexPath.row].owner, owner == vc.viewModel.returnUserID() {
            return UIMenu(title: "", children: [format, tag, edit, delete])
        } else {
            return UIMenu(title: "", children: [pay])
        }
    }

    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }

    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }

    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        guard let cell = collectionView.cellForItem(at: indexPath) as? GroupChatCollectionViewCell else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        // parameters.visiblePath = UIBezierPath(ovalIn: cell.messageLabel.bounds)
        return UITargetedPreview(view: cell.messageLabel, parameters: parameters)
    }
}
