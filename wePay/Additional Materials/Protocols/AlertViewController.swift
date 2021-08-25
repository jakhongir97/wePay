//
//  AlertViewController.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

protocol AlertViewController {
    func addErrorAlertView(error: (APIError, String?), completion: (() -> Void)?)
    func showAlert(title: String, message: String, buttonAction: (() -> Void)?)
    func showAlertWithTwoButtons(title: String, message: String, firstButtonText: String, firstButtonAction: (() -> Void)?, secondButtonText: String, secondButtonAction: (() -> Void)?)
}

extension AlertViewController where Self: UIViewController {
    func addErrorAlertView(error: (APIError, String?), completion: (() -> Void)? = nil) {
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

    func showAlert(title: String, message: String, buttonAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            buttonAction?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showAlertWithTwoButtons(title: String, message: String, firstButtonText: String, firstButtonAction: (() -> Void)? = nil, secondButtonText: String, secondButtonAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: firstButtonText, style: UIAlertAction.Style.default, handler: { _ in
            firstButtonAction?()
        }))
        alert.addAction(UIAlertAction(title: secondButtonText, style: UIAlertAction.Style.default, handler: { _ in
            secondButtonAction?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showAlertDestructive(title: String, message: String, buttonAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            buttonAction?()
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showAlertWithTextField(title: String, message: String, keyboardType: UIKeyboardType? = nil, buttonAction: ((_ text: String?) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { textField in
            textField.autocapitalizationType = .sentences
            textField.keyboardType = keyboardType ?? .alphabet
        }
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            guard let textField = alert.textFields?.first else {
                buttonAction?(nil)
                return
            }
            buttonAction?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
