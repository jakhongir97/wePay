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
        view().nameLabel.text = user.fullName
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
        
        let interaction = UIContextMenuInteraction(delegate: self)
        view().profileImageView.addInteraction(interaction)
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

// MARK: - Context Menu Delegate
extension ProfileViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            return self.makeContextMenu()
        })
    }
    
    func makeContextMenu() -> UIMenu {
        
        let edit = UIAction(title: "Edit", image: UIImage(systemSymbol: .pencil)) { _ in
            self.imagePicker.present()
        }
        
        let delete = UIAction(title: "Delete", image: UIImage(systemSymbol: .trashFill), attributes: [.destructive]) { _ in
            self.view().profileImageView.image = UIImage(systemSymbol: .personCropCircleFill)
            self.viewModel.updateUser(imageURL: nil)
        }
        
        return UIMenu(title: "", children: [edit, delete])
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        //parameters.visiblePath = UIBezierPath(ovalIn: view().profileImageView.bounds)
        return UITargetedPreview(view: view().profileImageView, parameters: parameters)
    }
}
