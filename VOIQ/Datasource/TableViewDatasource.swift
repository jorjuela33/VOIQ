//
//  TableViewDatasource.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData
import UIKit

final class TableViewDatasource <Provider: DataProvider, Delegate: DataSourceDelegate, Cell: UITableViewCell>: NSObject, UITableViewDataSource where Provider.ResultType == Cell.Element,
                                                                                                                                                     Delegate.Object == Provider.ResultType,
                                                                                                                                                     Cell: ConfigurableCell {
    private let cellClosure: ((Cell) -> Void)?
    private weak var delegate: Delegate!
    private let fetchedResultsDataProvider: Provider
    private let tableView: UITableView
    
    var commitEditingStyleClosure: ((UITableView, UITableViewCellEditingStyle, IndexPath) -> Void)?
    
    // MARK: Initialization
    
    init(tableView: UITableView, fetchedResultsDataProvider: Provider, delegate: Delegate, cellClosure: ((Cell) -> Void)? = nil) {
        self.fetchedResultsDataProvider = fetchedResultsDataProvider
        self.cellClosure = cellClosure
        self.delegate = delegate
        self.tableView = tableView
        
        super.init()
        
        self.fetchedResultsDataProvider.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    // MARK: Instance methods
    
    func processUpdates(_ updates: [Update]?) {
        defer{ delegate.datasourceDidUpdate() }
        
        guard let updates = updates, updates.isEmpty == false else {
            tableView.reloadData()
            return
        }
        
        tableView.beginUpdates()
        
        for update in updates {
            switch update {
            case .insert(let indexPath):
                tableView.insertRows(at: [indexPath], with: .fade)
                
            case .move(let indexPath, let newIndexPath):
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
                
            case .delete(let indexPath):
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            case .update(let indexPath):
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        
        tableView.endUpdates()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsDataProvider.numberOfSections()
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return []//fetchedResultsDataProvider.sectionIndexTitlesForTableView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsDataProvider.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = fetchedResultsDataProvider.object(at: indexPath)
        let identifier = delegate.cellIdentifier(for: element)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Cell
        cell.configure(for: element)
        cellClosure?(cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return commitEditingStyleClosure != nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        commitEditingStyleClosure?(tableView, editingStyle, indexPath)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsDataProvider.title(at: section)
    }
}

extension TableViewDatasource: DataProviderDelegate {
    
    // MARK: DataProviderDelegate
    
    func dataProviderDidUpdate(_ updates: [Update]) {
        DispatchQueue.main.async {
            self.processUpdates(updates)
        }
    }
}
