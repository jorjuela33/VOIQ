//
//  NSURLCredential+Additions.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import Foundation

extension URLCredentialStorage {
    
    // MARK: Instance methods
    
    /// Stores a new credential for the given user
    ///
    /// protectionSpace - The protection space for the credential
    ///                   this credential will use by default the
    ///                   stabilitas api URL
    func removeDefaultCrendentialFor(_ protectionSpace: URLProtectionSpace) {
        guard let credentials = credentials(for: protectionSpace) else { return }
        
        for credential in credentials.values {
            let options = [NSURLCredentialStorageRemoveSynchronizableCredentials: true]
            remove(credential, for: protectionSpace, options: options)
        }
    }
    
    /// Stores a new credential for the given user
    ///
    /// user            - The user identifier
    /// token           - The key provided for the ENDPOINT
    /// protectionSpace - The protection space for the credential
    ///                   this credential will use by default the
    ///                   stabilitas api URL
    func storeCredentialFor(_ user: String,
                            token: String,
                            protectionSpace: URLProtectionSpace = Server.current.protectionSpace) {
                                    
        let credential = URLCredential(user: user, password: token, persistence: .synchronizable)
        set(credential, for: protectionSpace)
    }
}
