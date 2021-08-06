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
        
        if let message = items[indexPath.row].message, let currency = items[indexPath.row].currency {
            cell.messageLabel.text = message.withCurreny(currency: currency)
        }
        if let timestamp = items[indexPath.row].timeStamp {
            cell.dateLabel.text = DateFormatter.string(timestamp: timestamp)
        }

        
        
        return cell
    }
    
    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20.0, height: 60)
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
        let format = UIAction(title: "Format", image: UIImage(systemSymbol: .dollarsignCircle)) { action in
            guard let vc = self.viewController as? GroupChatViewController else { return }
            guard let messageID = self.items[indexPath.row].id else { return }
            vc.viewModel.changeCurrencyMessage(messageID: messageID)
            
        }
        
        let edit = UIAction(title: "Edit", image: UIImage(systemSymbol: .pencil)) { action in
//            guard let vc = self.viewController as? GroupChatViewController else { return }
//            guard let messageID = self.items[indexPath.row].id else { return }
//            vc.viewModel.deleteMessage(messageID: messageID)
            
        }
        
        let delete = UIAction(title: "Delete", image: UIImage(systemSymbol: .trashFill)) { action in
            guard let vc = self.viewController as? GroupChatViewController else { return }
            guard let messageID = self.items[indexPath.row].id else { return }
            vc.viewModel.deleteMessage(messageID: messageID)
            
        }
        
        return UIMenu(title: "", children: [format, edit, delete])
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
