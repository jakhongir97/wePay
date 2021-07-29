//
//  UIButton.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerCurve = .continuous
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
}

extension UIButton {
    func setRightImage(image: UIImage, rightPadding : CGFloat? = nil) {
        let rightImageView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - (rightPadding ?? 68.0),
                                                       y: bounds.maxY/2 - 12,
                                                      width: 24,
                                                      height: 24))
        rightImageView.image?.withRenderingMode(.alwaysOriginal)
        rightImageView.image = image
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.layer.masksToBounds = true
        addSubview(rightImageView)
    }
}
