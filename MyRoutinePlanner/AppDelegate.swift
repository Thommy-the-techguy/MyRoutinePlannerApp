//
//  AppDelegate.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit
import NotificationCenter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let storage = Storage()
    
    func dispatchNotification() {
        let identifier = "morning-notification"
        let title = "Time to check your tasks"
        let body = "Don't forget to check your tasks for today!"
        let hour = 8
        let minute = 0
        let isDaily = true
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request)
    }
    
    func startAlarmCleaningThread() {
        DispatchQueue.global(qos: .userInitiated).async {
            let group = DispatchGroup()
            while true {
                print("Cleaning delivered reminders")
                group.enter()
                
                self.storage.removeInvalidReminders()
                
                group.leave()
                group.wait()
                
//                if self.storage.shouldRemoveReminders {
//                    print("True branch: \(self.storage.shouldRemoveReminders)")
////                    self.postReloadDataNotification()
//                } else {
//                    print("False branch: \(self.storage.shouldRemoveReminders)")
//                }
                
                sleep(5) // time in seconds
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
//                    UIApplication.shared.registerForRemoteNotifications()
                    self.dispatchNotification()
                }
            } else {
                print("Permission for push notifications denied.")
            }
        }
        
        startAlarmCleaningThread()
        
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

    func applicationWillTerminate(_ application: UIApplication) {
        //        NotificationCenter.default.post(Notification(name: Notification.Name("AppAboutToTerminate")))
//        let backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
//                // Handle expiration if needed
//        })
            
        NotificationCenter.default.post(Notification(name: Notification.Name("AppAboutToTerminate")))

            
//        // End the background task
//        UIApplication.shared.endBackgroundTask(backgroundTask)
    }
}
