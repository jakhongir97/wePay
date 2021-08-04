//
//  HomeViewController.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit
import CloudKit

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
        viewModel.fetchContacts()
    }
}

// MARK: - Networking
extension HomeViewController : HomeViewModelProtocol {
    func didFinishFetch(contacts: [User]) {
        for contact in contacts {
            if let telephone = contact.telephone, telephone.origin() == UserDefaults.standard.getPhone() {
                if let firstName = contact.firstName {
                    viewModel.updateUser(firstName: firstName)
                }
                if let lastName = contact.lastName {
                    viewModel.updateUser(lastName: lastName)
                }
            }
        }
    }
}

// MARK: - Other funcs
extension HomeViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.installBlurEffect()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = tabBarItem.title
        viewModel.delegate = self
    }
}
