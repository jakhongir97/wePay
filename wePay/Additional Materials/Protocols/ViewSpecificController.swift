//
//  ViewSpecificController.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 14/12/20.
//

import UIKit

protocol ViewSpecificController {
    associatedtype RootView: UIView
}

extension ViewSpecificController where Self: UIViewController {
    // swiftlint:disable force_cast
    func view() -> RootView {
        return self.view as! RootView
    }
}
