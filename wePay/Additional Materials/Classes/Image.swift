//
//  Image.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 22/12/20.
//

import UIKit

class Image: UIImageView {
    init(cornerRadius: Int? = nil) {
        super.init(frame: .zero)
        self.layer.cornerRadius = CGFloat(cornerRadius ?? 0)
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
