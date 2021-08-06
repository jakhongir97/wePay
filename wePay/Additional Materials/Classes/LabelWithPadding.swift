//
//  LabelWithPadding.swift
//  wePay
//
//  Created by Admin NBU on 05/08/21.
//

import UIKit

class LabelWithPadding: UILabel {
    override var intrinsicContentSize: CGSize {
        let defaultSize = super.intrinsicContentSize
        return CGSize(width: defaultSize.width + 32, height: defaultSize.height)
    }
}
