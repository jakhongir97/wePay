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
    private let viewModel = HomeViewModel()
    
    // MARK: - Data Providers

    // MARK: - Attributes
    
    // MARK: - Actions
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
}

// MARK: - Networking
extension ProfileViewController : HomeViewModelProtocol {
    func didFinishFetch() {
        
    }
}

// MARK: - Other funcs
extension ProfileViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.installBlurEffect()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = tabBarItem.title
        viewModel.delegate = self
    }
}
