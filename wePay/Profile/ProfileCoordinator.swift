//
//  ProfileCoordinator.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

final class ProfileCoordinator: Coordinator {
    internal var childCoordinators = [Coordinator]()
    internal var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    internal func start() {
        let vc = ProfileViewController()
        vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemSymbol: .gearshape), selectedImage: UIImage(systemSymbol: .gearshapeFill
        ))
        vc.tabBarItem.tag = 0
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}
