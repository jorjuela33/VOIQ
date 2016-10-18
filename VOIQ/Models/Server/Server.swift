//
//  Server.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import Foundation

final class Server: NSObject {
    
    /// the name for the server
    let name: String
   
    /// Returns the server selected for the user
    static var current: Server {
        guard
            /// the data
            let data = UserDefaults.standard.data(forKey: AppConfiguration.ServerEnviromentKey),
        
            /// the current server
            let server = NSKeyedUnarchiver.unarchiveObject(with: data) as? Server else { return Server.default }
        
        return server
    }
    
    /// The default server is initialized with the 
    /// production URL
    static var `default`: Server {
        return Server(name: "Prodution", url: AppConfiguration.Servers.PokemonProductionApiURL)
    }
    
    /// Returns the current URL with the api path
    var apiEndPoint: URL {
        return url.appendingPathComponent(AppConfiguration.ApiPathComponent)
    }
    
    /// the protection space for the current server
    var protectionSpace: URLProtectionSpace {
        return URLProtectionSpace(host: url.host!, port: url.port ?? 0, protocol: url.scheme, realm: nil, authenticationMethod: nil)
    }
    
    
    /// the current server url
    let url: URL
    
    // MARK: Initialization
    
    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let
            /// then name for the server
            name = aDecoder.decodeObject(forKey: "name") as? String,
            
            /// the URL
            let url = aDecoder.decodeObject(forKey: "URL") as? URL else { return nil }
        
        self.init(name: name, url: url)
    }
}

extension Server: NSCoding {
    
    // MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(url, forKey: "URL")
    }
}
