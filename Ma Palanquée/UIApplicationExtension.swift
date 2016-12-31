//
//  UIApplicationExtension.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 12/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

extension UIApplication
{
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let navigationController = controller as? UINavigationController
        {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController
        {
            if let selected = tabController.selectedViewController
            {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController
        {
            return topViewController(controller: presented)
        }
        return controller
    }
}
