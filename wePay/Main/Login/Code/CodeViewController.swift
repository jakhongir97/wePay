//
//  CodeViewController.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import UIKit
import FirebaseAuth

class CodeViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = CodeView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: MainCoordinator?
    private let viewModel = CodeViewModel()

    // MARK: - Attributes
    internal var phone: String?
    
    // MARK: - Actions
    @IBAction func continueButtonAction(_ sender: UIButton) {
        check()
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        navigationController?.fadePop()
    }
    

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        setupTextField()
        closeKeyboardOnOutsideTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

// MARK: - Networking
extension CodeViewController : CodeViewModelProtocol {
    func didFinishFetch() {
    }
    
    func check() {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }
        guard let verificationCode = view().codeTextField.text, !(verificationCode.isEmpty) else {
            showAlert(title: "Fill in the field", message: "")
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationID,
          verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                self.showAlert(title: error.localizedDescription, message: "")
                return
            }
            
            self.presentTabBarVC()
        }
    }
}

// MARK: - Other funcs
extension CodeViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.clearNavBar()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        viewModel.delegate = self
        view().codeTextField.becomeFirstResponder()
    }
    
    private func presentTabBarVC() {
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        tabBarVC.modalTransitionStyle = .crossDissolve
        navigationController?.present(tabBarVC, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CodeViewController : UITextFieldDelegate {
    
    func setupTextField() {
        view().codeTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = view().viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            view().endEditing(true)
            afterKeyboardAction()
        }
        return false
    }
    
    func afterKeyboardAction() {
        check()
    }
}

