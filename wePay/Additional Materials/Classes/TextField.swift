//
//  TextField.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

class TextField: UITextField {
    init(placeholderText: String? = nil, placeholderColor: UIColor? = nil, textColor: UIColor? = nil, borderStyle: UITextField.BorderStyle? = nil, keyboardType: UIKeyboardType? = nil) {
        super.init(frame: .zero)
        self.attributedPlaceholder = NSAttributedString(string: placeholderText ?? "", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor ?? .white])
        self.textColor = textColor
        self.borderStyle = borderStyle ?? .none
        self.keyboardType = keyboardType ?? .default
        self.keyboardAppearance = .dark
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
