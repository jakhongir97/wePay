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
    internal let viewModel = GroupChatViewModel()
    
    // MARK: - Data Providers
    private var groupChatDataProvider: GroupChatDataProvider?

    // MARK: - Attributes
    internal var group: Group?
    
    // MARK: - Actions
    @objc func add() {
        guard let group = group else { return }
        coordinator?.pushUsersVC(group: group)
    }
    @IBAction func payButtonAction(_ sender: UIButton) {
        sender.showAnimation{}
        guard let groupID = group?.id else { return }
        guard let message = view().textField.text, !(message.isEmpty) else {
            showAlert(title: "Enter the amount", message: "")
            return
        }
        viewModel.createMessage(message: message, groupID: groupID)
        view().textField.text = ""
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        setupTextField()
        
        guard let group = group else { return }
        title = group.name
        guard let groupID = group.id else { return }
        viewModel.getMessages(groupID: groupID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - Networking
extension GroupChatViewController : GroupChatViewModelProtocol {
    func didFinishFetch(messages: [Message]) {
        groupChatDataProvider?.items = messages
    }
    
    func didFinishFetch() {
        guard let groupID = group?.id else { return }
        viewModel.getMessages(groupID: groupID)
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view().collectionView.addGestureRecognizer(tap)
        
        let groupChatDataProvider = GroupChatDataProvider(viewController: self)
        groupChatDataProvider.collectionView = view().collectionView
        self.groupChatDataProvider = groupChatDataProvider
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


// MARK: - UITextFieldDelegate
extension GroupChatViewController : UITextFieldDelegate {
    
    func setupTextField() {
        view().textField.delegate = self
        view().textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.text = textField.text?.formattedWithSeparator
    }
    
}
