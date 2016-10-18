//
//  AppConfiguration.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import UIKit

struct AppConfiguration {
    
    static let ApiPathComponent = "api/v1"
    static let DefaultDebugFileURL = cacheFolder.appendingPathComponent("logFile.txt")
    static let FreshInstallCheckKey = "_FreshInstallCheckKey"
    static let ServerEnviromentKey = "_ServerEnviromentKey"
    
    static var cacheFolder: URL {
        return try! FileManager.default.url(for: .cachesDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
    }
    
    static var documentsFolder: URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    struct Servers {
        static let PokemonProductionApiURL = URL(string: "http://pokeapi.co")!
    }
}
