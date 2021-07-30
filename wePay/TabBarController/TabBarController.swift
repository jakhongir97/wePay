//
//  TabBarController.swift
//  wePay
//
//  Created by Admin NBU on 29/07/21.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Attributes
    internal let mainCoordinator = MainCoordinator(navigationController: UINavigationController())
    internal var groupCoordinator = GroupCoordinator(navigationController: UINavigationController())
    internal var profileCoordinator = ProfileCoordinator(navigationController: UINavigationController())
    
    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        createControllers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createControllers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
}

// MARK: - Other funcs
extension TabBarController {
    private func createControllers() {
        mainCoordinator.start()
        groupCoordinator.start()
        profileCoordinator.start()
        
        viewControllers = [mainCoordinator.navigationController, groupCoordinator.navigationController, profileCoordinator.navigationController]
    }
    
    private func appearanceSettings() {
        tabBar.installBlurEffect(tabBarHeight: self.tabBarController?.tabBar.frame.height ?? 0)
    }
}
