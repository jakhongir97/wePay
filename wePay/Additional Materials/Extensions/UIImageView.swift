//
//  UIImageView.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import SDWebImage
import UIKit

extension UIImageView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerCurve = .continuous
            layer.cornerRadius = newValue
        }
    }

    func setImage(with url: URL, placeholder: UIImage) {
        if url == URL(fileURLWithPath: "") {
            DispatchQueue.main.async {
                self.image = placeholder
            }
        } else {
            self.sd_setImage(with: url, placeholderImage: placeholder, options: [], completed: nil)
        }
    }
}
