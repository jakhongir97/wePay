//
//  Label.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

class Label: UILabel {
    init(font: UIFont, lines: Int, color: UIColor) {
        super.init(frame: .zero)
        self.font = font
        self.numberOfLines = lines
        self.textColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
