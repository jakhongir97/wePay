//
//  MainCoordinator.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit
import SFSafeSymbols

final class MainCoordinator: Coordinator {
    
    internal var childCoordinators = [Coordinator]()
    internal var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    internal func start() {
        let vc = HomeViewController()
        vc.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemSymbol: .house), selectedImage: UIImage(systemSymbol: .houseFill))
        vc.tabBarItem.tag = 0
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
}
