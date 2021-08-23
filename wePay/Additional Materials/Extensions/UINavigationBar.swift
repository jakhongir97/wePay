//
//  UINavigationBar.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

extension UINavigationBar {
    func installBlurEffect() {
        barStyle = .black
        shadowImage = UIImage()
        titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        isTranslucent = true
        setBackgroundImage(UIImage(), for: .default)
        backIndicatorImage = UIImage(systemSymbol: .arrowBackward)
        backIndicatorTransitionMaskImage = UIImage(systemSymbol: .arrowBackward)
        tintColor = UIColor.appColor(.blue)
        let statusBarHeight: CGFloat = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        var blurFrame = bounds
        blurFrame.size.height += statusBarHeight
        blurFrame.origin.y -= statusBarHeight
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.isUserInteractionEnabled = false
        blurView.frame = blurFrame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)
        blurView.layer.zPosition = -1
    }

    func clearNavBar() {
        shadowImage = UIImage()
        barTintColor = UIColor.appColor(.mainBackground)
        backgroundColor = .clear
        isTranslucent = false
        setBackgroundImage(UIImage(), for: .default)
        tintColor = .white
    }
}
