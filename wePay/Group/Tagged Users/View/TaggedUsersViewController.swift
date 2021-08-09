//
//  TaggedUsersViewController.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

class TaggedUsersViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = TaggedUsersView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: GroupCoordinator?
    private let viewModel = TaggedUsersViewModel()
    
    // MARK: - Data Providers
    private var taggedUsersDataProvider: TaggedUsersDataProvider?

    // MARK: - Attributes
    internal var groupID: String?
    internal var messageID: String?
    internal var groupUsers: [User]?
    internal var updatedTaggedUsers = [User]()
    internal var taggedUsers: [User]?
    
    // MARK: - Actions
    @objc func done() {
        guard let groupID = groupID else { return }
        guard let messageID = messageID else { return }
        viewModel.tagUsers(messageID: messageID, groupID: groupID, users: updatedTaggedUsers)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        guard let groupID = groupID else { return }
        guard let messageID = messageID else { return }
        guard let groupUsers = groupUsers else { return }
        viewModel.fetchTagedUsers(messageID: messageID, groupID: groupID, groupUsers: groupUsers)
    }
}

// MARK: - Networking
extension TaggedUsersViewController : TaggedUsersViewModelProtocol {
    func didFinishFetch(taggedUsers: [User]) {
        self.taggedUsers = taggedUsers
        updatedTaggedUsers = taggedUsers
        taggedUsersDataProvider?.items = taggedUsers
    }
}

// MARK: - Other funcs
extension TaggedUsersViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.installBlurEffect()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Tag Friends"
        let rightBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = rightBarButton
        viewModel.delegate = self
        
        let taggedUsersDataProvider = TaggedUsersDataProvider(viewController: self)
        taggedUsersDataProvider.collectionView = view().collectionView
        self.taggedUsersDataProvider = taggedUsersDataProvider
    }
}
