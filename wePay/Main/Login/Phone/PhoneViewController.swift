//
//  PhoneViewController.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import UIKit
import FirebaseAuth

class PhoneViewController: UIViewController, ViewSpecificController, AlertViewController {
    
    // MARK: - Root View
    typealias RootView = PhoneView
    
    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading: Bool = false
    internal var coordinator: MainCoordinator?
    private let viewModel = PhoneViewModel()

    // MARK: - Attributes
    
    // MARK: - Actions
    @IBAction func continueButtonAction(_ sender: UIButton) {
        auth()
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
extension PhoneViewController : PhoneViewModelProtocol {
    func didFinishFetch() {
    }
}

// MARK: - Other funcs
extension PhoneViewController {
    private func appearanceSettings() {
        navigationController?.navigationBar.clearNavBar()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        viewModel.delegate = self
    }
    
    private func auth() {
        guard let phone = view().phoneTextField.text?.origin(), !(phone.isEmpty) else {
            showAlert(title: "Fill in the field", message: "")
            return
        }
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
                if let error = error {
                    self.showAlert(title: error.localizedDescription, message: "")
                    return
                }
                
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.coordinator?.pushCodeVC(phone: phone)
            }
    }
}

// MARK: - UITextFieldDelegate
extension PhoneViewController : UITextFieldDelegate {
    
    func setupTextField() {
        view().phoneTextField.delegate = self
        view().phoneTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.text = textField.text?.display()
        
    }
    
    func afterKeyboardAction() {
        auth()
    }
}

