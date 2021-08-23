//
//  GroupsDataProvider.swift
//  wePay
//
//  Created by Admin NBU on 03/08/21.
//

import UIKit

final class GroupsDataProvider: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: - Outlets
    weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?

    internal var items = [Group]() {
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupCollectionViewCell.defaultReuseIdentifier, for: indexPath) as? GroupCollectionViewCell else { return UICollectionViewCell() }
        cell.label.text = items[indexPath.row].name

        if let summary = items[indexPath.row].summary, let intSummary = Int(summary) {
            switch intSummary {
            case 1 ... Int.max:
                cell.summaryLabel.textColor = UIColor.appColor(.green)
            case Int.min ..< 0:
                cell.summaryLabel.textColor = UIColor.appColor(.red)
            case 0:
                cell.summaryLabel.textColor = .clear
            default:
                break
            }
            cell.summaryLabel.text = intSummary.formattedWithSeparator
        }

        return cell
    }

    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32.0, height: 64)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = viewController as? GroupViewController else { return }
        vc.coordinator?.pushGroupChatVC(group: items[indexPath.row])
    }

    // MARK: - Context Menu
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            return self.makeContextMenu(indexPath: indexPath)
        }
    }

    func makeContextMenu(indexPath: IndexPath) -> UIMenu {
        guard let vc = self.viewController as? GroupViewController else { return UIMenu() }
        guard let groupID = self.items[indexPath.row].id else { return  UIMenu() }

        let share = UIAction(title: "Share", image: UIImage(systemSymbol: .squareAndArrowUp)) { _ in
            vc.viewModel.generateContentLink(groupID: groupID)
        }

        let edit = UIAction(title: "Edit", image: UIImage(systemSymbol: .pencil)) { _ in
            vc.editName(groupID: groupID)
        }

        let delete = UIAction(title: "Delete", image: UIImage(systemSymbol: .trashFill), attributes: [.destructive]) { _ in
            vc.viewModel.deleteGroup(groupID: groupID)
        }

        if let owner = items[indexPath.row].owner, owner == vc.viewModel.returnUserID() {
            return UIMenu(title: "", children: [share, edit, delete])
        } else {
            return UIMenu(title: "", children: [share])
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? GroupCollectionViewCell else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        // parameters.visiblePath = UIBezierPath(ovalIn: cell.messageLabel.bounds)
        return UITargetedPreview(view: cell, parameters: parameters)
    }
}
