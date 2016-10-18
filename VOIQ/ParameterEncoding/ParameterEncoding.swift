//
//  ParameterEncoding.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case DELETE, GET, POST, PATCH, PUT
}

enum ParameterEncoding {
    case json
    case url
    
    // MARK: Instance methods
    
    /// Creates a URL request by encoding parameters and applying them onto an existing request.
    ///
    /// URLRequest - The request to have parameters applied
    /// parameters - The parameters to apply
    func encode(_ request: URLRequest, parameters: Any?) -> (URLRequest, NSError?) {
        var mutableURLRequest = request
        guard let parameters = parameters else {
            return (request, nil)
        }
        
        var encodingError: NSError?
        
        switch self {
        case .json:
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.httpBody = data
            }
            catch {
                encodingError = error as NSError
            }
            
        case .url:
            guard let parameters = parameters as? JSONDictionary else { fatalError("array parameters is not implemented yet") }
            
            if let method = HTTPMethod(rawValue: mutableURLRequest.httpMethod!), allowEncodingInURL(method) {
                if var urlComponents = URLComponents(url: mutableURLRequest.url!, resolvingAgainstBaseURL: false) {
                    let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + queryString(parameters)
                    urlComponents.percentEncodedQuery = percentEncodedQuery
                    mutableURLRequest.url = urlComponents.url
                }
            }
            else {
                mutableURLRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.httpBody = queryString(parameters).data(using: String.Encoding.utf8)
            }
        }
        
        return (mutableURLRequest, encodingError)
    }
    
    // MARK: Private methods
    
    fileprivate func allowEncodingInURL(_ method: HTTPMethod) -> Bool {
        switch method {
        case .GET, .DELETE:
            return true
        default:
            return false
        }
    }
    
    fileprivate func queryString(_ parameters: [String: Any]) -> String {
        var components: [String] = []
        
        for key in parameters.keys.sorted(by: <) {
            guard let component = parameters[key] else { continue }
            
            components += queryComponent(key, component: component)
        }
        
        return components.joined(separator: "&")
    }
    
    fileprivate func queryComponent(_ key: String, component: Any) -> [String] {
        var components: [String] = []
        
        if let dictionary = component as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponent("\(key)[\(nestedKey)]", component: value)
            }
        } else if let array = component as? [Any] {
            for value in array {
                components += queryComponent("\(key)[]", component: value)
            }
        } else {
            components.append("\(scape(key))=\(scape("\(component)"))")
        }
        
        return components
    }
    
    fileprivate func scape(_ string: String) -> String {
        let allowedCharacterSet = CharacterSet(charactersIn:" =\"#%/<>?@\\^`{}[]|&+").inverted
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}
