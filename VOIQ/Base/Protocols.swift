//
//  Protocols.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData
import Foundation
import UIKit

typealias JSONDictionary = [String: Any]

protocol ApplicationActiveStateObserving: class, ObservableToken {
    /// Called when the application becomes active (or at launch if it's already active).
    func applicationDidBecomeActive()
    func applicationDidEnterBackground()
    func applicationDidFinishLaunching()
    func applicationDidReceiveMemoryWarning()
    func applicationWillEnterForeground()
    func applicationWillResignActive()
    func applicationWillTerminate()
}

protocol ApplicationLauncherObserving {
    
    /// Called when the application finish launching.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool
    
    /// Called when the application is launched via shorcut.
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void)
}

protocol ConfigurableCell {
    associatedtype Element
    
    static var identifier: String { get }
    
    /// Configure the content of the cell
    /// with the given object
    ///
    /// element - Any object containing the data
    func configure(for element: Element)
}

protocol ContextObservable: ObservableToken {
    /// Invoked when a new notification is fired
    func contextDidSaveNotification(_ notification: Notification)
}

protocol DataProvider: class {
    associatedtype ResultType: NSFetchRequestResult
    
    weak var delegate: DataProviderDelegate? { get set }
    
    var sectionIndexTitlesForTableView: [String]? { get }
    
    /// returns the number of sections
    func numberOfSections() -> Int
    
    /// returns the number of items in the given section
    func numberOfItems(in section: Int) -> Int
    
    /// returns the object for the given indexpath
    func object(at indexPath: IndexPath) -> ResultType
    
    /// reconfigure the current request
    func reconfigureFetchRequest(_ block: (NSFetchRequest<ResultType>) -> ())
    
    /// return the title for the section
    func title(at section: Int) -> String?
}

protocol DataSourceDelegate: class {
    associatedtype Object
    
    func cellIdentifier(for object: Object) -> String
    
    /// Invoked when the datasource ends updating
    func datasourceDidUpdate()
}

protocol DataProviderDelegate: class {
    func dataProviderDidUpdate(_ updates: [Update])
}

protocol ManagedObjectConvertible: class {
    associatedtype ResultType: NSFetchRequestResult
    
    /// The Core Data entity name
    static var entityName: String { get }
    
    /// The fetch request for the entity
    static var sortedFetchRequest: NSFetchRequest<ResultType> { get }
    
    /// returns the dictionary representantion
    var dictionaryValue: JSONDictionary { get }
    
    /// Delete all the objects from the entity, if saveChanges == true then the context
    /// will sync the changes inmediately, if saveChanged == false then the operation
    /// should sync the context
    static func deleteAll(in context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate?, shouldSyncChanges: Bool)
    
    /// Finds or create a new managed object
    static func findOrCreate(in context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate, configure: (Self) -> ()) -> Self
    
    /// Finds the first ocurrence of the object
    static func findOrFetch(in context: NSManagedObjectContext, matchingPredicate predicate: NSPredicate) -> Self?
    
    /// Inserts a new model in the given context
    @discardableResult
    static func insert(in context: NSManagedObjectContext, configure: (Self) -> ()) -> Self
    
    /// Inserts or return a model in the given context
    @discardableResult
    static func insertOrUpdate(in context: NSManagedObjectContext, dictionary: JSONDictionary) -> Self?
}

protocol ModelConvertible {
    /// The dictionary representation of the model
    var dictionaryValue: JSONDictionary { get }
    
    /// Initializes the model with a JSON dictionary
    init(dictionary: JSONDictionary)
}

protocol Modelable {
    /// The dictionary representation of the model
    var dictionaryValue: JSONDictionary { get }
    
    /// Initializes the model with a JSON dictionary
    init?(managedContext: NSManagedObjectContext, dictionary: JSONDictionary)
}

protocol ObservableToken: class {
    func addObserverToken(_ token: NSObjectProtocol)
}

protocol ProcessorType: class {
    /// Invoked when the app is launched from background
    func processInBackground()
}

protocol ViewController: class { }
