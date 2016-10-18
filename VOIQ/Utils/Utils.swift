//
//  Utils.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData
import UIKit

private let __dataBaseName = "VOIQ.sqlite"
private let storeURL = AppConfiguration.documentsFolder.appendingPathComponent(__dataBaseName)

/// Creates the main context for the app
func createMainContext() -> NSManagedObjectContext {
    /// Force unwrap this model, because this would only fail if we haven't
    /// included the xcdatamodel in our app resources.
    let model = NSManagedObjectModel.mergedModel(from: nil)!
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.persistentStoreCoordinator = persistentStoreCoordinator
    
    var error = createStore(persistentStoreCoordinator, atURL: storeURL)
    
    if persistentStoreCoordinator.persistentStores.isEmpty {
        /// Our persistent store does not contain irreplaceable data (which
        /// is why it's in the Caches folder). If we fail to add it, we can
        /// delete it and try again.
        destroyStore(for: context, atURL: storeURL)
        error = createStore(persistentStoreCoordinator, atURL: storeURL)
    }
    
    if persistentStoreCoordinator.persistentStores.isEmpty {
        error = createStore(persistentStoreCoordinator, atURL: nil, type: NSInMemoryStoreType)
        print(".Falling back to `.InMemory` store.")
    }
    
    if let error = error {
        print("Error creating SQLite store: \(error)")
    }
    
    return context
}

/// delete the given store
func destroyStore(for context: NSManagedObjectContext, atURL url: URL = storeURL, type: String = NSSQLiteStoreType) {
    do {
        if #available(iOS 9.0, *) {
            try context.persistentStoreCoordinator?.destroyPersistentStore(at: url, ofType: type, options: nil)
        }
        else if let persistentStore = context.persistentStoreCoordinator?.persistentStores.last {
            try context.persistentStoreCoordinator?.remove(persistentStore)
            try FileManager.default.removeItem(at: storeURL)
        }
    }
    catch {
        print("unable to destroy perstistent store at url: \(url), type: \(type)")
    }
}

/// Creates a non authenticated request
///
/// URL        - The host URL
/// method     - The HTTP Method
/// parameters - The parameters for the request
/// encoding   - The encoding type for this request
func authenticatedRequest(_ url: URL, method: HTTPMethod, parameters: [String: Any]? = nil, encoding: ParameterEncoding = .url) -> URLRequest {
    var mutableRequest = URLRequest(url: url)
    mutableRequest.httpMethod = method.rawValue
    mutableRequest.setValue("keep-alive", forHTTPHeaderField: "Connection")
    return encoding.encode(mutableRequest, parameters: parameters).0
}

/// Registers a array transformer
///
/// name - the name of the transformer
/// registrationToken -  The dispach token to make sure is invoked once
func registerArrayValueTransformer(with name: String) {
    ValueTransformer.registerTransformerWithName(name, transform: { array in
        guard let array = array else { return nil }
        
        do {
            return try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted) as NSData
        }
        catch {
            return nil
        }
        
        }, reverseTransform: { (data: NSData?) -> NSArray? in
            guard let data = data else { return nil }
            
            do {
                return try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? NSArray
            }
            catch {
                return nil
            }
    })
}

// MARK: Private methods

@discardableResult
private func createStore(_ persistentStoreCoordinator: NSPersistentStoreCoordinator, atURL URL: Foundation.URL?, type: String = NSSQLiteStoreType) -> NSError? {
    var error: NSError?
    do {
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        try persistentStoreCoordinator.addPersistentStore(ofType: type, configurationName: nil, at: URL, options: options)
    }
    catch let storeError as NSError {
        error = storeError
    }
    
    return error
}
