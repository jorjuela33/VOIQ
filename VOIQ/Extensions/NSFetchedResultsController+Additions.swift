//
//  NSFetchedResultController+Additions.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData

extension NSFetchedResultsController {
 
    func fetchObjects() {
        do {
            try performFetch()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
}
