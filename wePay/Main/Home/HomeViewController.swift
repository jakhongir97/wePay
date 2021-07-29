//
//  HomeViewController.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

class HomeViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = HomeView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: MainCoordinator?
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
extension HomeViewController : HomeViewModelProtocol {
    func didFinishFetch() {
        
    }
}

// MARK: - Other funcs
extension HomeViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.installBlurEffect()
        viewModel.delegate = self
    }
}
