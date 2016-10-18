//
//  GetPokemonsOperation.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData
import OperationKit

final class GetPokemonsOperation: BaseGroupOperation {
    
    private let cacheFile = AppConfiguration.cacheFolder.appendingPathComponent("pokemons.json")
    private let downloadOperation: DownloadOperation
    private let parseOperation: ParseOperation<Pokemon>
    
    // MARK: Initialization
    
    init(context: NSManagedObjectContext, limit: Int, offset: Int) {
        let url = Server.current.apiEndPoint.appendingPathComponent("pokemon")
        let request = authenticatedRequest(url, method: .GET, parameters: ["limit": limit, "offset": offset])
        
        downloadOperation = DownloadOperation(request: request, cacheFile: cacheFile)
        parseOperation = ParseOperation(cacheFile: cacheFile, context: context, path: "objects")
        
        downloadOperation.addObserver(NetworkObserver())
        parseOperation.addDependency(downloadOperation)
        
        super.init(operations: [downloadOperation, parseOperation])
        
        name = "Get Pokemons Operation"
        
        addObserver(BackgroundObserver())     
    }
    
    // MARK: Overrided methods
    
    override func operationDidFinish(_ operation: Foundation.Operation, withErrors errors: [Error]) {
        super.operationDidFinish(operation, withErrors: errors)
        
        guard operation === downloadOperation, downloadOperation.response?.statusCode != 200 else { return }
        
        produceAlertOperation()
    }
    
    // MARK: Private methods
    
    private final func produceAlertOperation() {
        guard hasProducedAlert && userInitiated == true else { return }
        
        let alertOperation = AlertOperation(title: "Attention", message: "Unable to fetch the pokemons. Try again!")
        alertOperation.userInitiated = userInitiated
        produceOperation(alertOperation)
        hasProducedAlert = true
    }
}
