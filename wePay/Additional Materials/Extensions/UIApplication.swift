//
//  UIApplication.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

extension UIApplication {
    class func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBeforeFlag")
    }

    class func saveFirstLaunch() {
        UserDefaults.standard.set(true, forKey: "hasBeenLaunchedBeforeFlag")
        UserDefaults.standard.synchronize()
    }
}
