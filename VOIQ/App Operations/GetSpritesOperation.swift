//
//  GetSpritesOperation.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData
import OperationKit

final class GetSpritesOperation: BaseGroupOperation {
    
    private let cacheFile: URL
    private let downloadOperation: DownloadOperation
    private let parseOperation: ParseGetSpriteOperation
    
    // MARK: Initialization
    
    init(context: NSManagedObjectContext, path: String, pokemonId: Int16) {
        cacheFile = AppConfiguration.cacheFolder.appendingPathComponent("\(arc4random()).json")
        
        let url = AppConfiguration.Servers.PokemonProductionApiURL.appendingPathComponent(path)
        let request = authenticatedRequest(url, method: .GET)
        
        downloadOperation = DownloadOperation(request: request, cacheFile: cacheFile)
        parseOperation = ParseGetSpriteOperation(cacheFile: cacheFile, context: context, pokemonId: pokemonId)
        
        downloadOperation.addObserver(NetworkObserver())
        parseOperation.addDependency(downloadOperation)
        
        super.init(operations: [downloadOperation, parseOperation])
        
        name = "Get Sprite \(path) Operation"
        
        addObserver(BackgroundObserver())
    }
}
