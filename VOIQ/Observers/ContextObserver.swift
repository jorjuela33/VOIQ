//
//  ContextObserver.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData
import Foundation

protocol ManagedObjectContextObservable: class {
    func managedObjectContext(_ context: NSManagedObjectContext, didUpdate update: [String: [NSManagedObject]])
}

final class ContextObserver {
    
    fileprivate let context: NSManagedObjectContext
    fileprivate var internalPredicate: NSPredicate?
    
    weak var delegate: ManagedObjectContextObservable?
    
    // MARK: Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextDidSaveNotification(_:)),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: nil)
    }
    
    convenience init(context: NSManagedObjectContext, entityName: String, predicate: NSPredicate) {
        self.init(context: context)
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else { fatalError() }
        
        observeEntity(entityDescription, predicate: predicate)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Instance methods
    
    /// add a new predicate observer for the given entity
    ///
    /// name      - the name of the entity in the database
    /// predicate - a custom predicate to evaluate the objects
    final func observeEntityWithName(_ name: String, predicate: NSPredicate) {
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: context) else { fatalError() }
        
        observeEntity(entity, predicate: predicate)
    }
    
    /// add a new predicate observer for the given entity
    ///
    /// entity    - the entity description
    /// predicate - a custom predicate to evaluate the objects
    final func observeEntity(_ entity: NSEntityDescription, predicate: NSPredicate) {
        guard let name = entity.name else { fatalError() }
        
        var predicates = [NSPredicate(format: "entity.name == %@", name), predicate]
        let __predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        if internalPredicate == nil {
            internalPredicate = __predicate
        }
        else if let predicate = internalPredicate {
            predicates = [predicate, __predicate]
            internalPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
    }
    
    // MARK: Notification methods
    
    @objc func managedObjectContextDidSaveNotification(_ notification: Notification) {
        guard 
            /// the predicate
            let predicate = internalPredicate,
            
            /// the saved context
            let context = notification.object as? NSManagedObjectContext,
            
            /// the user info
            let userInfo = notification.userInfo , context !== self.context else { return }
        
        var results: [String: [NSManagedObject]] = [:]
        
        if let insertedObjects = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> , insertedObjects.isEmpty == false {
            results[NSInsertedObjectsKey] = insertedObjects.filter({ predicate.evaluate(with: $0) })
        }
        
        if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> , deletedObjects.isEmpty == false {
            results[NSDeletedObjectsKey] = deletedObjects.filter({ predicate.evaluate(with: $0) })
        }
        
        if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> , updatedObjects.isEmpty == false {
            results[NSUpdatedObjectsKey] = updatedObjects.filter({ predicate.evaluate(with: $0) })
        }
        
        guard results.values.reduce([], { $0 + $1 }).count > 0 else { return }
        
        DispatchQueue.main.async {
            self.delegate?.managedObjectContext(context, didUpdate: results)
        }
    }
}
