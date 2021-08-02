//
//  LaunchScreenViewController.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

class LaunchScreenViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = LaunchScreenView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: MainCoordinator?
    private let viewModel = LaunchScreenViewModel()
    
    // MARK: - Attributes
    override var prefersStatusBarHidden: Bool { return true }
    
    // MARK: - Actions
    @objc func errorRetryButtonAction(_ sender: Button) {
        
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        animate()
        //UserDefaults.standard.resetDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - Networking
extension LaunchScreenViewController : LaunchScreenViewModelProtocol {
    func showAlertClosure(error: (APIError, String?)) {
        if view().errorView == nil {
            view().createErrorView(errorType: error.0)
            view().errorView.retryButton.addTarget(self, action: #selector(errorRetryButtonAction), for: .touchUpInside)
        } else {
            view().errorView.isHidden = false
        }
    }
    
    func showActivityIndicator() {
        view().activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        view().activityIndicator.stopAnimating()
    }
    
    func didFinishFetch() {
        
    }
    
}

// MARK: - Other funcs
extension LaunchScreenViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
    }
    
    private func animate() {
        UIView.transition(with: self.view().imageView,
                          duration: 0.75,
                          options: .transitionCrossDissolve,
                          animations: {
                            self.view().imageView.image = UIImage(systemSymbol: .lightbulbFill)
                          },
                          completion: { _ in
                            UserDefaults.standard.isRegistered() ?  self.presentTabBarVC() : self.coordinator?.pushPhoneVC()
                          })
    }
    
    private func presentTabBarVC() {
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        tabBarVC.modalTransitionStyle = .crossDissolve
        navigationController?.present(tabBarVC, animated: true)
    }
}

