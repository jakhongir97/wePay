//
//  PhoneView.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import UIKit

final class PhoneView: CustomView {
    // MARK: - Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var phoneTextField: UITextField! {
        didSet {
            phoneTextField.setLeftPaddingPoints(16)
        }
    }
    @IBOutlet var continueButton: UIButton!
}
