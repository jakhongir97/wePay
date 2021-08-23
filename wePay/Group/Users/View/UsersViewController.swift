//
//  UsersViewController.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

class UsersViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = UsersView

    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading = false
    internal var coordinator: GroupCoordinator?
    private let viewModel = UsersViewModel()

    // MARK: - Data Providers
    private var usersDataProvider: UsersDataProvider?

    // MARK: - Attributes
    internal var group: Group?
    internal var updatedUsers = [User]()
    internal var allUsers: [User]?
    internal var contacts: [User]?

    // MARK: - Actions
    @objc func done() {
        guard let group = group else { return }
        guard let allUsers = allUsers else { return }
        viewModel.updateUsers(group: group, oldUsers: allUsers.filter({ $0.isMember ?? true }), newUsers: updatedUsers.filter({ $0.isMember ?? true }))
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        viewModel.fetchContacts()
        guard let groupID = group?.id else { return }
        viewModel.fetchGroupUsers(groupID: groupID)
    }
}

// MARK: - Networking
extension UsersViewController: UsersViewModelProtocol {
    func didFinishFetch(contacts: [User]) {
        self.contacts = contacts
    }

    func didFinishFetch(users: [User]) {
        self.allUsers = users
        updatedUsers = users
        usersDataProvider?.items = users
    }

    func didFinishFetch(groupUsers: [User]) {
        guard let contacts = contacts else { return }
        viewModel.fetchUsers(groupUsers: groupUsers, contacts: contacts)
    }

    func didFinishFetchRemoveUsers() {
    }
}

// MARK: - Other funcs
extension UsersViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.installBlurEffect()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Add Friends"
        let rightBarButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = rightBarButton
        viewModel.delegate = self

        let usersDataProvider = UsersDataProvider(viewController: self)
        usersDataProvider.collectionView = view().collectionView
        self.usersDataProvider = usersDataProvider
    }
}
