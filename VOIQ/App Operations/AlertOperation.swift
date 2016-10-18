//
//  AlertOperation.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import UIKit
import OperationKit

class AlertOperation: OperationKit.Operation {
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    let presentationContext: UIViewController?
    
    /// If we want to delay the presentation for the alert
    /// we can set this value greater than 0, sometimes 
    /// we want to delay the presentation in order to allow
    /// the loading view to hide first
    var delayInterval: TimeInterval = 0
    
    /// The title for the alert controller
    var title: String? {
        get {
            return alertController.title
        }
        
        set {
            alertController.title = newValue
            name = newValue
        }
    }
    
    /// The mesage for the alert controller
    var message: String? {
        get {
            return alertController.message
        }
        
        set {
            alertController.message = newValue
        }
    }
    
    // MARK: Initialization
    
    init(presentationContext: UIViewController? = nil, title: String? = nil, message: String? = nil) {
        let _presentationContext = presentationContext ?? UIApplication.shared.keyWindow?.rootViewController
        self.presentationContext = _presentationContext?.presentedViewController ?? _presentationContext
        
        super.init()
        
        self.message = message
        self.title = title
        
        name = "Alert Operation"
    }
        
    // MARK: Instance methods
    
    /// Adds a new action to the presentation controller
    ///
    /// title   - The title for the action
    /// style   - The action style
    /// handler - A block to invoke when the actions is performed
    func addAction(_ title: String, style: UIAlertActionStyle = .default, handler: @escaping (AlertOperation) -> Void = { _ in }) {
        let action = UIAlertAction(title: title, style: style) { [weak self] _ in
            if let strongSelf = self {
                handler(strongSelf)
            }
            
            self?.finish()
        }
        
        alertController.addAction(action)
    }
    
    // MARK: Overrided methods
    
    override func execute() {
        guard let presentationContext = presentationContext , UIApplication.shared.applicationState == .active else {
            finish()
            return
        }
        
        DispatchQueue.main.async {
            if self.alertController.actions.isEmpty {
                self.addAction("OK")
            }
            
            let dispatchTime = DispatchTime.now() + Double(Int64(self.delayInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                presentationContext.present(self.alertController, animated: true, completion: nil)
            })
        }
    }
}
