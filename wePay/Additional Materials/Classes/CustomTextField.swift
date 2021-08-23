//
//  CustomTextField.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 23/12/20.
//

import UIKit

class CustomTextField: UITextField {
    let padding = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
