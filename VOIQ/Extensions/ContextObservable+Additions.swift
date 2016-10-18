//
//  ContextObservable+Additions.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData
import Foundation

extension ContextObservable {
    
    /// Setups all the active notifications for the current observer
    func setupContextActiveNotifications() {
        addObserverToken(NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave,
                                                                                 object: nil,
                                                                                 queue: nil) { [weak self] note in
                
            guard let strongSelf = self else { return }
                
            strongSelf.contextDidSaveNotification(note)
        })
    }
}
