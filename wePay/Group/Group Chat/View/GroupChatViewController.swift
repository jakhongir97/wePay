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
    private var keyboardHelper: KeyboardHelper?
    
    // MARK: - Data Providers
    private var groupChatDataProvider: GroupChatDataProvider?

    // MARK: - Attributes
    internal var group: Group?
    internal var users: [User]?
    
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
        guard let users = users else { return }
        viewModel.createMessage(message: message, groupID: groupID, tags: users)
        view().textField.text = ""
    }
    
    func editMessage(messageID: String) {
        showAlertWithTextField(title: "Edit mesage", message: "amount") { name in
            if let message = name , !(message.isEmpty) {
                self.viewModel.changeValueMessage(messageID: messageID, newMessage: message)
            }
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        setupTextField()
        setupKeyboard()
        guard let group = group else { return }
        title = group.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        guard let groupID = group?.id else { return }
        viewModel.fetchGroupUsers(groupID: groupID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - Networking
extension GroupChatViewController : GroupChatViewModelProtocol {
    func didFinishFetchWithTaggedUsers(messages: [Message]) {
        groupChatDataProvider?.items = messages
    }
    
    func didFinishFetch(groupUsers: [User]) {
        self.users = groupUsers
        guard let groupID = group?.id else { return }
        viewModel.getMessages(groupID: groupID)
    }
    
    func didFinishFetch(messages: [Message]) {
        //groupChatDataProvider?.items = messages
        guard let users = users else { return }
        guard let groupID = group?.id else { return }
        viewModel.fetchWithTaggedUsers(groupID: groupID, groupUsers: users, messages: messages)
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
        
        let groupChatDataProvider = GroupChatDataProvider(viewController: self)
        groupChatDataProvider.collectionView = view().collectionView
        self.groupChatDataProvider = groupChatDataProvider
    }
    
    func setupKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view().collectionView.addGestureRecognizer(tap)
        
        keyboardHelper = KeyboardHelper { [unowned self] animation, keyboardFrame, duration in
            switch animation {
            case .keyboardWillShow:
                view().collectionView.scrollToLast()
            case .keyboardWillHide:
                view().collectionView.scrollToLast()
            }
        }
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
