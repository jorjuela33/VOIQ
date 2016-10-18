//
//  ParseOperation.swift
//  tpaga
//
//  Created by Jorge Orjuela on 9/26/16.
//  Copyright © 2016 TPaga. All rights reserved.
//

import CoreData
import OperationKit

enum SyncPolicy {
    /// Time based sync
    case sync
    
    /// Merge the values from both remote and local
    case merge
    
    /// Copy all the values from the remote
    case copy
    
    case none
}

/// An default `Operation` to parse the results from a download operation.
class ParseOperation<Element: ManagedObjectConvertible>: OperationKit.Operation {
    
    private let cacheFile: URL
    private let context: NSManagedObjectContext
    private let path: String?

    var syncPolicy: SyncPolicy = .none
    
    // MARK: Initialization
    
    init(cacheFile: URL, context: NSManagedObjectContext, path: String? = nil) {
        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        importContext.mergePolicy = NSOverwriteMergePolicy
        
        self.context = importContext
        self.cacheFile = cacheFile
        self.path = path
        
        super.init()
        
        name = "Parse Operation"
    }
    
    // MARK: Overrided methods
    
    override func execute() {
        guard let data = try? Data(contentsOf: cacheFile) else {
            finish()
            return
        }
        
        do {
            var response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            if let
                /// the path in the response
                path = path,
                
                /// the response dictionary
                let JSONResponse = response as? NSDictionary,
                
                /// the response object
                let responseObject = JSONResponse.value(forKeyPath: path) {
                
                response = responseObject
            }
            
            if syncPolicy == .copy {
                Element.deleteAll(in: context, matchingPredicate: nil, shouldSyncChanges: false)
            }
            
            /// Running the code in the right context block
            context.perform {
                if let elements = response as? [JSONDictionary] {
                    self.insertElements(elements)
                }
                else if let dictionary = response as? JSONDictionary {
                    self.insertElemenWith(dictionary)
                }
                else {
                    let error = NSError(domain: NSCocoaErrorDomain, code: NSPropertyListReadCorruptError, userInfo: nil)
                    self.finishWithError(error)
                    return
                }
                
                self.context.saveChanges({ self.finishWithError($0) })
            }
        }
        catch {
            finishWithError(error as NSError)
        }
    }
    
    // MARK: Private methods

    private func insertElements(_ elements: [JSONDictionary]) {
        for dictionary in elements {
            insertElemenWith(dictionary)
        }
    }
    
    private func insertElemenWith(_ dictionary: JSONDictionary) {
        Element.insertOrUpdate(in: context, dictionary: dictionary)
    }
}
