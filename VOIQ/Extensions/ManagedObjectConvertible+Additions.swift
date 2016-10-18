//
//  ManagedObjectConvertible+Additions.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData

extension ManagedObjectConvertible where Self: NSManagedObject {
    
    /// returns the dictionary representation for the model
    var dictionaryValue: JSONDictionary {
        let modelMirror = Mirror(reflecting: self)
        var propertyKeysAndValues: JSONDictionary = [:]
        for child in modelMirror.children {
            guard let propertyName = child.label else { continue }
            
            propertyKeysAndValues[propertyName] = child.value
        }
        
        return propertyKeysAndValues
    }
    
    /// Delete all the objects from the entity, if saveChanges == true then the context
    /// will sync the changes inmediately, if saveChanged == false then the operation
    /// should sync the context
    static func deleteAll(in context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate?, shouldSyncChanges: Bool) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        fetchRequest.predicate = predicate
        
        context.executeFetchRequest(fetchRequest, completionHandler: { results, error in
            guard let elements = results as? [Self] , error == nil else { return }
            
            for element in elements {
                context.delete(element)
            }
            
            guard shouldSyncChanges == true else { return }
            
            context.saveChanges({
                guard let error = $0 else { return }
                
                print("error deleting the objects in the entity \(Self.entityName), error: \(error)")
            })
        })
    }
    
    /// Find/Create the object in core data
    static func findOrCreate(in context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate, configure: (Self) -> ()) -> Self {
        let object = fetch(in: context) { fetchRequest in
            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.fetchLimit = 1
        }
        
        guard let existingObject = object.first else {
            let newObject: Self = context.insertObject()
            configure(newObject)
            return newObject
        }
        
        configure(existingObject)
        return existingObject
    }
    
    /// Finds the first ocurrence of the object
    static func findOrFetch(in context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        var materializedObject: Self?
        
        context.performAndWait {
            if let object = self.materializedObject(in: context, matchingPredicate: predicate) {
                materializedObject = object
            }
            else {
                materializedObject = fetch(in: context) { request in
                    request.predicate = predicate
                    request.returnsObjectsAsFaults = false
                    request.fetchLimit = 1
                }.first
            }
        }
        
        return materializedObject
    }
    
    /// Fetch the object with the configured request
    static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        var results: [Self] = []
        
        context.performAndWait {
            results = try! context.fetch(request)
        }
        
        return results
    }
    
    /// Inserts a new model in the given context
    static func insert(in context: NSManagedObjectContext, configure: (Self) -> ()) -> Self {
        let newObject: Self = context.insertObject()
        configure(newObject)
        return newObject
    }
    
    /// returns the materialized object if exists
    static func materializedObject(in moc: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self? {
        for obj in moc.registeredObjects where !obj.isFault && !obj.isDeleted {
            guard let res = obj as? Self , predicate.evaluate(with: res) else { continue }
            return res
        }
        
        return nil
    }
}
