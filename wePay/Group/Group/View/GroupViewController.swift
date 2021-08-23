//
//  GroupViewController.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

enum Link : String {
    case join
    case show
}

class GroupViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = GroupView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: GroupCoordinator?
    internal let viewModel = GroupViewModel()
    internal var link: Link?
    internal var groupID: String?
    
    // MARK: - Data Providers
    private var groupsDataProvider: GroupsDataProvider?

    // MARK: - Attributes
    
    // MARK: - Actions
    @objc func create() {
        showAlertWithTextField(title: "Creating Group", message: "Enter name for your new group") { name in
            if let name = name , !(name.isEmpty) {
                self.viewModel.createGroup(name: name)
            }
        }
    }
    
    func editName(groupID: String) {
        showAlertWithTextField(title: "Edit Name", message: "Enter new name for your group") { name in
            if let name = name , !(name.isEmpty) {
                self.viewModel.editGroup(groupID: groupID, newName: name)
            }
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchGroups()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

// MARK: - Networking
extension GroupViewController : GroupViewModelProtocol {
    func didFinishFetch(url: URL) {
        share(text: "I'm sharing", url: url)
    }
    
    func didFinishFetch() {
        viewModel.fetchGroups()
    }
    
    func didFinishFetch(groups: [Group]) {
        //groupsDataProvider?.items = groups
        viewModel.fetchWithSummary(groups: groups)
    }
    
    func didFinishFetch(groupsWithSummary: [Group]) {
        groupsDataProvider?.items = groupsWithSummary
        guard let groupID = groupID , let link = link else { return }
        switch link {
        case .show:
            for (index,group) in groupsWithSummary.enumerated() {
                if group.id == groupID {
                    let indexPath = IndexPath(item: index, section: 0)
                    groupsDataProvider?.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
                    coordinator?.pushGroupChatVC(group: group)
                }
            }
        case .join:
            if !groupsWithSummary.contains(where: { $0.id == groupID }) {
                viewModel.addUser(groupID: groupID)
            }
        }
        resetAttributes()
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
    
    func resetAttributes(){
        groupID = nil
        link = nil
    }
}
