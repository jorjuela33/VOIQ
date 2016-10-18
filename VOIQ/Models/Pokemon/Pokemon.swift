//
//  Pokemon.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData

private let __imagesStringURLSValueTransformerName = "__imagesStringURLSValueTransformerName"
private let __spritesValueTransformerName = "__spritesValueTransformerName"

final class Pokemon: NSManagedObject {

    @NSManaged fileprivate(set) var id: Int16
    @NSManaged var imagesStringURLS: Set<String>
    @NSManaged fileprivate(set) var name: String
    @NSManaged fileprivate(set) var ratio: String
    @NSManaged fileprivate(set) var stringURL: String
    @NSManaged fileprivate(set) var sprites: Set<String>
    
    /// the url for the pokemon
    var url: URL? {
        return URL(string: stringURL)
    }
    
    // MARK: Class methods
    
    override class func initialize() {
        super.initialize()
        registerArrayValueTransformer(with: __imagesStringURLSValueTransformerName)
        registerArrayValueTransformer(with: __spritesValueTransformerName)
    }
}

extension Pokemon: ManagedObjectConvertible {
    
    class var entityName: String { return "Pokemon" }
    
    // Allowable keys for a `Pokemons`'s dictionary representation.
    enum DictionaryKey: String {
        case id          = "national_id"
        case name        = "name"
        case ratio       = "male_female_ratio"
        case resourceUri = "resource_uri"
        case sprites     = "sprites"
        case stringURL   = "url"
    }
    
    static var sortedFetchRequest: NSFetchRequest<Pokemon> {
        let request = NSFetchRequest<Pokemon>(entityName: Pokemon.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.fetchBatchSize = 20
        request.returnsObjectsAsFaults = false
        return request
    }
    
    class func insertOrUpdate(in context: NSManagedObjectContext, dictionary: JSONDictionary) -> Pokemon? {
        guard
            /// the national id
            let id = dictionary[DictionaryKey.id.rawValue] as? Int,
        
            /// the name
            let name = dictionary[DictionaryKey.name.rawValue] as? String,
        
            /// the sprites
            let sprites = dictionary[DictionaryKey.sprites.rawValue] as? [JSONDictionary] else { return nil }
        
        let predicate = NSPredicate(format: "id == %i", id)
        return findOrCreate(in: context, matchingPredicate: predicate) {
            $0.id = Int16(id)
            $0.name = name
            $0.ratio = dictionary[DictionaryKey.stringURL.rawValue] as? String ?? "Unknown"
            $0.stringURL = dictionary[DictionaryKey.stringURL.rawValue] as? String ?? ""
            
            for sprite in sprites {
                guard let resourceUri = sprite[DictionaryKey.resourceUri.rawValue] as? String else { continue }
                
                $0.sprites.insert(resourceUri)
            }
        }
    }
}
