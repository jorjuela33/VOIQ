//
//  ParseGetSpriteOperation.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 TPaga. All rights reserved.
//

import CoreData
import OperationKit

class ParseGetSpriteOperation: OperationKit.Operation {
    
    private let cacheFile: URL
    private let context: NSManagedObjectContext
    private let pokemonId: Int16
    
    // MARK: Initialization
    
    init(cacheFile: URL, context: NSManagedObjectContext, pokemonId: Int16) {
        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        importContext.mergePolicy = NSOverwriteMergePolicy
        
        self.context = importContext
        self.cacheFile = cacheFile
        self.pokemonId = pokemonId
        
        super.init()
        
        name = "Parse Get Sprites Operation"
    }
    
    // MARK: Overrided methods
    
    override func execute() {
        guard let data = try? Data(contentsOf: cacheFile) else {
            finish()
            return
        }
        
        do {
            guard let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSONDictionary else {
                let error = NSError(domain: NSCocoaErrorDomain, code: NSPropertyListReadCorruptError, userInfo: nil)
                self.finishWithError(error)
                return
            }
            
            context.perform {
                if
                    /// the path for the image
                    let pathImage = response["image"] as? String,
                    
                    /// the pokemon
                    let pokemon = Pokemon.findOrFetch(in: self.context, matchingPredicate: NSPredicate(format: "id == %i", self.pokemonId)) {
                
                    pokemon.imagesStringURLS.insert(pathImage)
                }
            }
            
            context.saveChanges({ self.finishWithError($0) })
        }
        catch {
            finishWithError(error as NSError)
        }
    }
}
