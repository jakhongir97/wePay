//
//  GroupChatViewController.swift
//  wePay
//
//  Created by Admin NBU on 04/08/21.
//

import UIKit

class GroupChatViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = GroupChatView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: GroupCoordinator?
    private let viewModel = GroupChatViewModel()
    
    // MARK: - Data Providers
    private var groupChatDataProvider: GroupChatDataProvider?

    // MARK: - Attributes
    internal var group: Group?
    
    // MARK: - Actions
    @objc func add() {
        guard let group = group else { return }
        coordinator?.pushUsersVC(group: group)
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        guard let group = group else { return }
        title = group.name
    }
}

// MARK: - Networking
extension GroupChatViewController : GroupChatViewModelProtocol {
    func didFinishFetch() {
    }
}

// MARK: - Other funcs
extension GroupChatViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.installBlurEffect()
        navigationController?.navigationBar.prefersLargeTitles = true
        let rightBarButton = UIBarButtonItem(image: UIImage(systemSymbol: .plusCircleFill), style: .plain, target: self, action: #selector(add))
        navigationItem.rightBarButtonItem = rightBarButton
        viewModel.delegate = self
        
        let groupChatDataProvider = GroupChatDataProvider(viewController: self)
        groupChatDataProvider.collectionView = view().collectionView
        self.groupChatDataProvider = groupChatDataProvider
    }
}
