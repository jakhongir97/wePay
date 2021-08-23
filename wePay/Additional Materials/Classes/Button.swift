//
//  Button.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 22/12/20.
//

import UIKit

class Button: UIButton {
    init(image: UIImage? = nil, tag: Int, textFont: UIFont? = nil, textColor: UIColor? = nil, titleText: String? = nil, backgroundColor: UIColor? = nil) {
        super.init(frame: .zero)
        self.setImage(image, for: .normal)
        self.tag = tag
        self.titleLabel?.font = textFont
        self.setTitle(titleText, for: .normal)
        self.backgroundColor = backgroundColor
        setTitleColor(textColor, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
