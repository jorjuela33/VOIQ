//
//  ModelConvertible+Additions.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import Foundation

extension ModelConvertible {
    
    /// Returns a `Dictionary` containing all key-pars for the current model
    var dictionaryValue: JSONDictionary {
        let modelMirror = Mirror(reflecting: self)
        var propertyKeysAndValues: JSONDictionary = [:]
        for child in modelMirror.children {
            guard let propertyName = child.label else { continue }
            
            propertyKeysAndValues[propertyName] = child.value
        }
        
        return propertyKeysAndValues
    }
}
