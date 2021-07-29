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
        tabBar.tintColor = .white
        tabBar.isTranslucent = true
        tabBar.backgroundImage = UIImage()
        tabBar.barTintColor = .clear
        tabBar.backgroundColor = .clear
        tabBar.layer.backgroundColor = UIColor.clear.cgColor
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        var blurFrame = tabBar.bounds
        blurFrame.size.height += tabBarHeight
        blurFrame.origin.y -= tabBarHeight
        let blurView  = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.isUserInteractionEnabled = false
        blurView.frame = blurFrame
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tabBar.addSubview(blurView)
        blurView.layer.zPosition = -1
    }
}
