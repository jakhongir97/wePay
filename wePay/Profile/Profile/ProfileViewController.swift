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
    
    // MARK: - Data Providers

    // MARK: - Attributes
    
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
//        guard let firstName = user.firstName , let lastName = user.lastName else { return }
//        title = "\(firstName) \(lastName)"
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
    }
}
