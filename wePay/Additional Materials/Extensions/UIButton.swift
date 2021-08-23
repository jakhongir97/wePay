//
//  UIButton.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

@IBDesignable extension UIButton {
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerCurve = .continuous
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
    }
}

extension UIButton {
    func setRightImage(image: UIImage, rightPadding: CGFloat? = nil) {
        let rightImageView = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width - (rightPadding ?? 68.0),
                                                       y: bounds.maxY / 2 - 12,
                                                      width: 24,
                                                      height: 24))
        rightImageView.image?.withRenderingMode(.alwaysOriginal)
        rightImageView.image = image
        rightImageView.contentMode = .scaleAspectFit
        rightImageView.layer.masksToBounds = true
        addSubview(rightImageView)
    }
}
