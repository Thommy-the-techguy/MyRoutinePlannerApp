//
//  AppDelegate.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit
import NotificationCenter
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let storage = Storage()
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskPlanner")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
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
                
                
                sleep(5) // time in seconds
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    print("Permission for push notifications granted.")
                }
            } else {
                print("Permission for push notifications denied.")
            }
        }
        
        storage.fetchTasks()
        
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
        NotificationCenter.default.post(Notification(name: Notification.Name("AppAboutToTerminate")))
    }
}
