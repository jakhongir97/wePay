//
//  CodeView.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import UIKit

final class CodeView: CustomView {
    // MARK: - Outlets
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var codeTextField: UITextField! {
        didSet {
            codeTextField.setLeftPaddingPoints(16)
        }
    }
    @IBOutlet var continueButton: UIButton!
}
