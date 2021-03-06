//
//  ProfilView.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

final class ProfileView: CustomView {
    // MARK: - Outlets
    @IBOutlet var profileImageView: UIImageView! {
        didSet {
            profileImageView.isUserInteractionEnabled = true
            profileImageView.layer.cornerRadius = 50
        }
    }
    @IBOutlet var fullNameView: UIView! {
        didSet {
            fullNameView.isUserInteractionEnabled = true
            fullNameView.layer.cornerRadius = 25
            fullNameView.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var firstNameTextField: UITextField! {
        didSet {
            firstNameTextField.isUserInteractionEnabled = false
        }
    }
    @IBOutlet var lastNameTextField: UITextField! {
        didSet {
            lastNameTextField.isUserInteractionEnabled = false
        }
    }
}
