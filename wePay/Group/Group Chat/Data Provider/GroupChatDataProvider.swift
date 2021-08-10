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
        if let vc = self.viewController as? GroupChatViewController {
            cell.viewController = vc
        }
        
        if let message = items[indexPath.row].message, let currency = items[indexPath.row].currency {
            cell.messageLabel.text = message.withCurreny(currency: currency)
        }
        if let timestamp = items[indexPath.row].timeStamp {
            cell.dateLabel.text = DateFormatter.string(timestamp: timestamp)
        }
        
        if let users = items[indexPath.row].taggedUsers {
            cell.userTagsDataProvider?.items = users
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
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { suggestedActions in
            return self.makeContextMenu(indexPath: indexPath)
        }
    }
    
    func makeContextMenu(indexPath: IndexPath) -> UIMenu {
        
        guard let vc = self.viewController as? GroupChatViewController else { return UIMenu()}
        guard let messageID = self.items[indexPath.row].id else { return UIMenu() }
        guard let groupID = vc.group?.id else { return UIMenu() }
        
        let pay = UIAction(title: "Pay", image: UIImage(systemSymbol: .creditcardFill)) { action in
            vc.viewModel.payMessage(messageID: messageID, groupID: groupID, isPaid: true)
        }
        
        let format = UIAction(title: "Format", image: UIImage(systemSymbol: .dollarsignCircle)) { action in
            vc.viewModel.changeCurrencyMessage(messageID: messageID)
        }
        
        let tag = UIAction(title: "Tag", image: UIImage(systemSymbol: .tag)) { action in
            guard let groupUsers = vc.users else { return }
            vc.coordinator?.pushTaggedUsersVC(groupID: groupID, messageID: messageID, groupUsers: groupUsers)
            
        }
        
        let edit = UIAction(title: "Edit", image: UIImage(systemSymbol: .pencil)) { action in
            
        }
        
        let delete = UIAction(title: "Delete", image: UIImage(systemSymbol: .trashFill)) { action in
            vc.viewModel.deleteMessage(messageID: messageID, groupID: groupID)
        }
        
        return UIMenu(title: "", children: [pay, format, tag, edit, delete])
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
        //parameters.visiblePath = UIBezierPath(ovalIn: cell.messageLabel.bounds)
        return UITargetedPreview(view: cell.messageLabel, parameters: parameters)
    }
    
}
