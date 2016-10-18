//
//  AppDelegate.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    fileprivate var context = createMainContext()
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if NSClassFromString("XCTestCase") != nil { return true }
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        UIApplication.shared.statusBarStyle = .lightContent
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -5, vertical: -60), for: .default)
        UINavigationBar.appearance().barTintColor = UIColor.blue
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18)]
        
        setupContextActiveNotifications()
        window?.rootViewController = UINavigationController(rootViewController: PokemonsViewController(context: context))
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

extension AppDelegate: ContextObservable {
    
    // MARK: ContextObservable
    
    func addObserverToken(_ token: NSObjectProtocol) { /* No Op */ }
    
    func contextDidSaveNotification(_ notification: Notification) {
        context.performMergeChangesFromContextDidSaveNotification(notification)
    }
}
