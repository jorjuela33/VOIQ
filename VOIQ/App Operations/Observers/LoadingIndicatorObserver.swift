//
//  LoadingOperation.swift
//  NextDots
//
//  Created by Jorge Orjuela on 9/21/16.
//  Copyright © 2016 Jorge Orjuela. All rights reserved.
//

import Foundation
import MBProgressHUD
import OperationKit

final class LoadingIndicatorObserver: ObservableOperation {
    
    private var cancelled = false
    private let delay: TimeInterval
    private let loadingView: MBProgressHUD
    
    // MARK: Initialization
    
    init(title: String = "Cargando...", delay: TimeInterval = 0) {
        self.delay = delay
        loadingView = MBProgressHUD(window: UIApplication.shared.windows.last)
        loadingView.removeFromSuperViewOnHide = true
        loadingView.labelText = title
    }
    
    // MARK: ObservableOperation
    
    func operationDidStart(_ operation: OperationKit.Operation) {
        DispatchQueue.main.async {
            UIApplication.shared.windows.first?.addSubview(self.loadingView)
            self.loadingView.show(true)
        }
    }
    
    func operation(_ operation: OperationKit.Operation, didProduceOperation newOperation: Foundation.Operation) { /* No OP */ }
    
    func operationDidFinish(_ operation: OperationKit.Operation, errors: [Error]) {
        let dispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            guard self.cancelled == false else { return }
            
            self.cancelled = true
            self.loadingView.hide(true)
        })
    }
}
