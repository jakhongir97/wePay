//
//  GroupCoordinator.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

final class GroupCoordinator: Coordinator {
    
    internal var childCoordinators = [Coordinator]()
    internal var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    internal func start() {
        let vc = GroupViewController()
        vc.tabBarItem = UITabBarItem(title: "Groups", image: UIImage(systemSymbol: .personCropCircleBadgePlus), selectedImage: UIImage(systemSymbol: .personCropCircleFillBadgePlus))
        vc.tabBarItem.tag = 0
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
}
