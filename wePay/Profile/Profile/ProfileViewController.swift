//
//  ProfileViewController.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

class ProfileViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = HomeView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: ProfileCoordinator?
    private let viewModel = ProfileViewModel()
    
    // MARK: - Data Providers

    // MARK: - Attributes
    
    // MARK: - Actions
    @objc func signOut() {
        viewModel.signOut()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
}

// MARK: - Networking
extension ProfileViewController : ProfileViewModelProtocol {
    func didFinishFetch() {
        UserDefaults.standard.removePhone()
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
