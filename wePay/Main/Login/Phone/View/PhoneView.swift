//
//  PhoneView.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import UIKit

final class PhoneView: CustomView {
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!{
        didSet {
            phoneTextField.setLeftPaddingPoints(16)
        }
    }
    @IBOutlet weak var continueButton: UIButton!
    
}
