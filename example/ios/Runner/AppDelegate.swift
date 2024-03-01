import UIKit
import Flutter
import UserNotifications
import Qualtrics

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

@available(iOS 10.0, *)
extension AppDelegate {
    // Application is in the foreground
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let _ = Qualtrics.shared.handleLocalNotification(response: response, displayOn: self.window!.rootViewController!)
        completionHandler()
    }
}

extension AppDelegate {
    override func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let _ = Qualtrics.shared.handleLocalNotification(notification, displayOn: self.window!.rootViewController!)
    }
    
    override func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        
    }
}
