//
//  UITabBar.swift
//  wePay
//
//  Created by Admin NBU on 30/07/21.
//

import UIKit

extension UITabBar {
    func installBlurEffect(tabBarHeight: CGFloat) {
        tintColor = .white
        isTranslucent = true
        backgroundImage = UIImage()
        barTintColor = .clear
        backgroundColor = .clear
        layer.backgroundColor = UIColor.clear.cgColor
        //let tabBarHeight: CGFloat = frame.height 
        var blurFrame = bounds
        blurFrame.size.height += tabBarHeight
        blurFrame.origin.y -= tabBarHeight
        let blurView  = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.isUserInteractionEnabled = false
        blurView.frame = blurFrame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        blurView.layer.zPosition = -1
    }
}
