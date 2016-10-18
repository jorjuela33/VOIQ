//
//  ViewController+Additions.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import AVFoundation
import OperationKit
import UIKit

private let operationQueue = OperationKit.OperationQueue()

extension ViewController where Self: UIViewController {
    
    /// Adds a tap gesture that hides the keyboard
    func addTapGesture() {
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizerDidTap(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    /// creates the default refresh control used in the app
    func refreshControl(with title: String, selector: Selector) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: selector, for: .valueChanged)
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 10), NSForegroundColorAttributeName: UIColor.black]
        refreshControl.attributedTitle = NSAttributedString(string: title, attributes: attributes)
        return refreshControl
    }
    
    // MARK: Private methods
    
    private final func enqueueAlertOperation(with message: String) {
        let alertOperation = AlertOperation(title: "Atención", message: message)
        alertOperation.userInitiated = true
        operationQueue.addOperation(alertOperation)
    }
    
    private final func enqueueAlertSettingsOperation() {
        let alertOperation = AlertOperation(title: "Atención", message: "Por favor autorice el acceso a la camara.")
        alertOperation.userInitiated = true
        
        alertOperation.addAction("Cancelar", style: .cancel, handler: { _ in })
        alertOperation.addAction("Settings", style: .default, handler: { _ in
            guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else { return }
            
            UIApplication.shared.openURL(settingsURL)
        })
        
        operationQueue.addOperation(alertOperation)
    }
}

private extension UIViewController {
    
    @objc func gestureRecognizerDidTap(_ gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
