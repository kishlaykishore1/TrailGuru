//
//  UITabBarController.swift
//

import UIKit

extension UITabBarController {
    func removeTabbarItemsText() {
        tabBar.items?.forEach {
            $0.title = ""
           // $0.imageInsets = UIEdgeInsets(top: -12, left: 0, bottom: 12, right: 0)
        }
    }
}
