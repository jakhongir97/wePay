//
//  AlertViewController.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

protocol AlertViewController {
    func addErrorAlertView(error: (APIError, String?), completion: (() -> ())?)
    func showAlert(title: String, message: String, buttonAction: (()->())?)
    func showAlertWithTwoButtons(title: String, message: String, firstButtonText: String, firstButtonAction: (()->())?, secondButtonText: String, secondButtonAction: (()->())?)
}

extension AlertViewController where Self: UIViewController {
    func addErrorAlertView(error: (APIError, String?), completion: (() -> ())? = nil) {
        switch error.0 {
        case .requestFailed:
            showAlert(title: AlertViewTexts.noInternetConnecton.rawValue.toLocalized(), message: AlertViewTexts.laterMessage.rawValue.toLocalized(), buttonAction: completion)
        case .notAuthorized:
            showAlert(title: AlertViewTexts.noAuthorizationTitle.rawValue.toLocalized(), message: AlertViewTexts.noAuthorizationMessage.rawValue.toLocalized()) {
//                let vc = ProfileViewController()
//                vc.fromVC = true
//                self.navigationController?.present(vc, animated: true, completion: nil)
            }
        case .fromMessage:
            guard let message = error.1 else { return }
            showAlert(title: message, message: "", buttonAction: completion)
        default:
            showAlert(title: AlertViewTexts.errorMSG.rawValue.toLocalized(), message: AlertViewTexts.laterMessage.rawValue.toLocalized(), buttonAction: completion)
        }
    }
    
    func showAlert(title: String, message: String, buttonAction: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
            buttonAction?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertWithTwoButtons(title: String, message: String, firstButtonText: String, firstButtonAction: (()->())? = nil, secondButtonText: String, secondButtonAction: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: firstButtonText, style: UIAlertAction.Style.default, handler: { (action) in
            firstButtonAction?()
        }))
        alert.addAction(UIAlertAction(title: secondButtonText, style: UIAlertAction.Style.default, handler: { (action) in
            secondButtonAction?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertWithTextField(title: String, message: String, buttonAction: ((_ text: String?) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Продолжить", style: UIAlertAction.Style.default, handler: { (action) in
            guard let textField =  alert.textFields?.first else {
                buttonAction?(nil)
                return
            }
            buttonAction?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
