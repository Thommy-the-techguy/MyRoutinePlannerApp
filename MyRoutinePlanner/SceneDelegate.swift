//
//  SceneDelegate.swift
//  MyRoutinePlanner
//
//  Created by Артем Чижик on 14.01.24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // configuring window
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
        
        // notify storage that app has been loaded
        NotificationCenter.default.post(Notification(name: Notification.Name("AppLoaded")))
        
        // creating view controllers
        let (todayTabVC, inboxTabVC, searchTabVC, browseTabVC) = (TodayTabViewController(), InboxTabViewController(), SearchTabViewController(), BrowseTabViewController())
        
        // setting tab bar items title and image
        todayTabVC.tabBarItem = UITabBarItem(title: "Today", image: UIImage(systemName: "calendar"), tag: 0)
        inboxTabVC.tabBarItem = UITabBarItem(title: "Inbox", image: UIImage(systemName: "tray"), tag: 1)
        searchTabVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        browseTabVC.tabBarItem = UITabBarItem(title: "Browse", image: UIImage(systemName: "folder"), tag: 3)
        
        // creating corresponding navigation controllers
        let (navControllerTodayTab, navControllerInboxTab, navControllerSearchTab, navControllerBrowseTab) = (UINavigationController(rootViewController: todayTabVC), UINavigationController(rootViewController: inboxTabVC), UINavigationController(rootViewController: searchTabVC), UINavigationController(rootViewController: browseTabVC))
        
        // creating list of view controllers to add to tabBarController
        let viewControllers = [navControllerTodayTab,
                               navControllerInboxTab,
                               navControllerSearchTab,
                               navControllerBrowseTab]
        
        // creating and setting up tabBarController
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(viewControllers, animated: true)
        if #available(iOS 15, *) {
            tabBarController.tabBar.scrollEdgeAppearance = .init()
        }
        
        // making tabBarController with navController and corresponding view a root controller for window
        window?.rootViewController = tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//        NotificationCenter.default.post(Notification(name: Notification.Name("AppLoaded")))
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

