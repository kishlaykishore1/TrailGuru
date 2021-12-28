//
//  UIApplication.swift
//

import UIKit

extension UIApplication {
    
    class var shortVersionString: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }else{
            return ""
        }
    }
    
    class var appName: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return name
        }else{
            return ""
        }
    }
   
    class func topViewController(controller: UIViewController? = (Double(UIDevice.current.systemVersion) ?? 10.0) < 13.0 ?
        UIApplication.shared.keyWindow?.rootViewController : UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController  ) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
//        if let presented = controller as? SSASideMenu {
//            presented.hideMenuViewController()
//            return presented.contentViewController?.children.first
//        }
        return controller
    }
}


extension Bundle {
    var releaseVersionNumber: String? {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return Bundle.main.infoDictionary!["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "v\(releaseVersionNumber ?? "1.0.0")"
    }
}
