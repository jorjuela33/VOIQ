//
//  ApplicationStateObserving+Additions.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import UIKit

extension ApplicationActiveStateObserving {
    
    func setupNotifications() {
        addObserverToken(NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: nil) { [weak self] notification in
            guard let observer = self else { return }
            observer.applicationDidEnterBackground()
        })
        
        addObserverToken(NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillEnterForeground, object: nil, queue: nil) { [weak self] notification in
            guard let observer = self else { return }
            observer.applicationWillEnterForeground()
        })
        
        addObserverToken(NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] notification in
            guard let observer = self else { return }
            observer.applicationDidBecomeActive()
        })
        
        addObserverToken(NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] notification in
            guard let observer = self else { return }
            observer.applicationWillResignActive()
        })
        
        addObserverToken(NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: nil) { [weak self] notification in
            guard let observer = self else { return }
            observer.applicationDidReceiveMemoryWarning()
        })
        
        addObserverToken(NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil, queue: nil) { [weak self] notification in
            guard let observer = self else { return }
            observer.applicationDidFinishLaunching()
        })
        
        addObserverToken(NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillTerminate, object: nil, queue: nil) { [weak self] notification in
            guard let observer = self else { return }
            observer.applicationWillTerminate()
        })
    }
}
