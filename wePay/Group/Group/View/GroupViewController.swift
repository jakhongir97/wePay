//
//  GroupViewController.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

class GroupViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = GroupView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: GroupCoordinator?
    internal let viewModel = GroupViewModel()
    
    // MARK: - Data Providers
    private var groupsDataProvider: GroupsDataProvider?

    // MARK: - Attributes
    
    // MARK: - Actions
    @objc func create() {
        showAlertWithTextField(title: "Creating Group", message: "Enter name for your new group") { name in
            self.viewModel.createGroup(name: name ?? "")
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        viewModel.fetchGroups()
    }
}

// MARK: - Networking
extension GroupViewController : GroupViewModelProtocol {
    func didFinishFetch() {
        viewModel.fetchGroups()
    }
    
    func didFinishFetch(groups: [Group]) {
        groupsDataProvider?.items = groups
    }
}

// MARK: - Other funcs
extension GroupViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.installBlurEffect()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = tabBarItem.title
        let rightBarButton = UIBarButtonItem(image: UIImage(systemSymbol: .plusCircleFill), style: .plain, target: self, action: #selector(create))
        navigationItem.rightBarButtonItem = rightBarButton
        viewModel.delegate = self
        
        let groupsDataProvider = GroupsDataProvider(viewController: self)
        groupsDataProvider.collectionView = view().collectionView
        self.groupsDataProvider = groupsDataProvider
    }
}
