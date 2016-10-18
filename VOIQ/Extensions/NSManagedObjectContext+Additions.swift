//
//  NSManagedObjectContext+Additions.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    /// Returns the entity description
    func entityForName(_ name: String) -> NSEntityDescription {
        guard
            // store coordinator
            let persistentStoreCoordinator = persistentStoreCoordinator,
        
            // entity
            let entity = persistentStoreCoordinator.managedObjectModel.entitiesByName[name]  else { fatalError("Conditions fails") }
        
        return entity
    }
    
    /// Execute the request in the current context
    func executeRequest(_ request: NSPersistentStoreRequest, completionHandler: @escaping (NSError?) -> Void) {
        perform {
            var error: NSError?
            
            do {
                try self.execute(request)
            }
            catch let requestError as NSError {
                error = requestError
            }
            
            completionHandler(error)
        }
    }
    
    /// Execute the request in the current context
    func executeFetchRequest(_ request: NSFetchRequest<NSFetchRequestResult>, completionHandler: @escaping ([AnyObject], NSError?) -> Void){
        perform {
            var results: [AnyObject] = []
            var error: NSError?
            do {
                results = try self.fetch(request)
            } catch let requestError as NSError {
                error = requestError
            }
            
            completionHandler(results, error)
        }
    }
    
    /// Inserts a new object in the current context
    ///
    /// Element - The core data model to insert
    func insertObject<Element: NSManagedObject>() -> Element where Element: ManagedObjectConvertible {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: Element.entityName, into: self) as? Element else { fatalError("Wrong object type") }
        
        return obj
    }
    
    /// Save the changes in the current context
    func saveChanges(_ completionHandler: @escaping (NSError?) -> Void) {
        perform {
            var error: NSError?
            
            if self.hasChanges {
                do {
                    try self.save()
                }
                catch let saveError as NSError {
                    error = saveError
                }
            }
            
            completionHandler(error)
        }
    }
    
    /// Merges the changes specified in notification object received from another context's
    /// In the context queue
    func performMergeChangesFromContextDidSaveNotification(_ notification: Notification) {
        perform {
            self.mergeChanges(fromContextDidSave: notification)
        }
    }
}
