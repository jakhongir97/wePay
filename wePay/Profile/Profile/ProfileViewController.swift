//
//  ProfileViewController.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

class ProfileViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = ProfileView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: ProfileCoordinator?
    private let viewModel = ProfileViewModel()
    internal var imagePicker: ImagePicker!
    private var interactionImageView: UIContextMenuInteraction?
    private var interactionFullNameView: UIContextMenuInteraction?
    private var keyboardHelper: KeyboardHelper?
    
    // MARK: - Data Providers
    
    // MARK: - Attributes
    internal var user: User?
    
    // MARK: - Actions
    @objc func signOut() {
        showAlertDestructive(title: "Are you sure?", message: "Are you sure you want to log out?") {
            self.viewModel.signOut()
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        //closeKeyboardOnOutsideTap()
        setupKeyboard()
        viewModel.getUserInfo()
    }
}

// MARK: - Networking
extension ProfileViewController : ProfileViewModelProtocol {
    func didFinishFetchUpload(url: String) {
        view().profileImageView.sd_setImage(with: URL(string: url), completed: nil)
    }
    
    func didFinishFetch() {
        UserDefaults.standard.removePhone()
        let window = UIApplication.shared.windows[0] as UIWindow
        let launchScreenVC = LaunchScreenViewController()
        let navController = UINavigationController(rootViewController: launchScreenVC)
        let mainCoordinator = MainCoordinator(navigationController: navController)
        launchScreenVC.coordinator = mainCoordinator
        
        window.rootViewController = navController
    }
    
    func didFinishFetch(user: User) {
        self.user = user
        view().firstNameTextField.text = user.firstName
        view().lastNameTextField.text = user.lastName
        if let imageURL = user.imageURL {
            view().profileImageView.sd_setImage(with: URL(string: imageURL), completed: nil)
        }
    }
}

// MARK: - Other funcs
extension ProfileViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.installBlurEffect()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = tabBarItem.title
        let rightBarButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        navigationItem.rightBarButtonItem = rightBarButton
        viewModel.delegate = self
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        interactionImageView = UIContextMenuInteraction(delegate: self)
        if let interactionImageView = interactionImageView {
            view().profileImageView.addInteraction(interactionImageView)
        }
        
        interactionFullNameView = UIContextMenuInteraction(delegate: self)
        if let interactionFullNameView = interactionFullNameView {
            view().fullNameView.addInteraction(interactionFullNameView)
        }
    }
}

// MARK: - Image Picker Delegate
extension ProfileViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image = image else { return }
        guard let user = user else { return }
        guard let imageData = image.pngData() else { return }
        guard let fileName = user.imageName else { return }
        self.viewModel.uploadUserPicture(with: imageData, fileName: fileName)
    }
}

// MARK: - UITextFieldDelegate
extension ProfileViewController : UITextFieldDelegate {
    
    func editMode() {
        view().firstNameTextField.isUserInteractionEnabled = true
        view().lastNameTextField.isUserInteractionEnabled = true
        self.view().firstNameTextField.becomeFirstResponder()
    }
    
    func setupKeyboard() {
        view().firstNameTextField.delegate = self
        view().lastNameTextField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view().addGestureRecognizer(tap)
        
        keyboardHelper = KeyboardHelper { [unowned self] animation, keyboardFrame, duration in
            switch animation {
            case .keyboardWillShow:
                break
            case .keyboardWillHide:
                view().firstNameTextField.isUserInteractionEnabled = false
                view().lastNameTextField.isUserInteractionEnabled = false
                afterKeyboardAction()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = view().viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            dismissKeyboard()
            afterKeyboardAction()
        }
        return false
    }
    
    @objc func dismissKeyboard() {
        view().endEditing(true)
    }
    
    func afterKeyboardAction() {
        if let firstName = view().firstNameTextField.text, !(firstName.isEmpty) {
            viewModel.updateUser(firstName: firstName)
        }
        if let lastName = view().lastNameTextField.text, !(lastName.isEmpty) {
            viewModel.updateUser(lastName: lastName)
        }
        
    }
}

// MARK: - Context Menu Delegate
extension ProfileViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu(interaction: interaction)
        })
    }
    
    func makeContextMenu(interaction: UIContextMenuInteraction) -> UIMenu {
        
        let edit = UIAction(title: "Edit", image: UIImage(systemSymbol: .pencil)) { _ in
            switch interaction {
            case self.interactionImageView:
                self.imagePicker.present()
            case self.interactionFullNameView:
                self.editMode()
            default:
                break
            }
        }
        
        let delete = UIAction(title: "Delete", image: UIImage(systemSymbol: .trashFill), attributes: [.destructive]) { _ in
            self.view().profileImageView.image = UIImage(systemSymbol: .personCropCircleFill)
            self.viewModel.updateUser(imageURL: nil)
        }
        
        switch interaction {
        case interactionImageView:
            return UIMenu(title: "", children: [edit, delete])
        case interactionFullNameView:
            return UIMenu(title: "", children: [edit])
        default:
            return UIMenu()
        }
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration, interaction: interaction)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration, interaction: interaction)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration, interaction: UIContextMenuInteraction) -> UITargetedPreview? {
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        //parameters.visiblePath = UIBezierPath(ovalIn: view().profileImageView.bounds)
        guard let view = interaction.view else { return nil }
        return UITargetedPreview(view: view, parameters: parameters)
    }
}
