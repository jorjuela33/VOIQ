//
//  BaseOperation.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import Foundation
import OperationKit

class BaseGroupOperation: GroupOperation {
    
    var hasProducedAlert = false
    
    // MARK: Instance methods
    
    /// Display an alert for the failed operation, the subclass can
    /// override this method in order to add custom messages
    ///
    /// error - The error for the operation
    func produceAlert(_ error: NSError) {
        guard hasProducedAlert == false && userInitiated == true else { return }
        
        let errorReason = (error.domain, error.code, error.userInfo[OperationConditionKey] as? String ?? "")
        var message = ""
        
        switch errorReason {
        case (OperationErrorDomainCode, OperationErrorCode.conditionFailed.rawValue, ReachabilityCondition.name):
            message = "No se pudo conectar al servidor. Asegurese de que el device esta conectado a internet."
            
        case (NSCocoaErrorDomain, NSPropertyListReadCorruptError, ""):
            message = "No se pudo descargar la información. Intente mas tarde."
            
        default:
            return
        }
        
        hasProducedAlert = true
        
        let alertOperation = AlertOperation(title: "Atención!", message: message)
        produceOperation(alertOperation)
    }
    
    // MARK: ObservableOperation
    
    override func operationDidFinish(_ operation: Foundation.Operation, withErrors errors: [Error]) {
        guard let error = errors.first else { return }
        
        produceAlert(error as NSError)
    }
}
