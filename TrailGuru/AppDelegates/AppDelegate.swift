//
//  AppDelegate.swift
//  TrailGuru-ios
//
//  Created by kishlay kishore on 17/02/21.
//

import UIKit
import Firebase
import CoreLocation
import UserNotifications
import IQKeyboardManagerSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    var locationManager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        FirebaseApp.configure()
      
      // Confirm Delegete and request for Notification permission
      notificationCenter.delegate = self
      let options: UNAuthorizationOptions = [.alert, .sound, .badge]
      notificationCenter.requestAuthorization(options: options) {
          (didAllow, error) in
        guard didAllow else { return }
        self.getNotificationSettings()
      }
      
      if CLLocationManager.locationServicesEnabled() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
          locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
          locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
          locationManager.startUpdatingLocation()
        @unknown default:
          break
        }
      } else {
        print("Location services are not enabled")
      }
        //Global.clearAllAppUserDefaults()
        if MemberModel.getMemberModel() != nil {
            isUserLogin(true)
        } else {
            isUserLogin(false)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
  
  func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      print("Notification settings: \(settings)")
      guard settings.authorizationStatus == .authorized else { return }
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
 
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    //
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("i am not available in simulator :( \(error)")
  }
  
}

// MARK: - Check User Login
extension AppDelegate {
    func isUserLogin(_ isLogin: Bool) {
        if isLogin {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let welcomeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.window?.rootViewController = UINavigationController(rootViewController: welcomeVC)
            self.window?.makeKeyAndVisible()
            
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let welcomeVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.window?.rootViewController = UINavigationController(rootViewController: welcomeVC)
            self.window?.makeKeyAndVisible()
        }
    }
}
