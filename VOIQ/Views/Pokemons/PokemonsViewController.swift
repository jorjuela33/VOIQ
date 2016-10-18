//
//  PokemonsViewController.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import CoreData
import OperationKit
import UIKit

private let paginationLimit = 20

class PokemonsViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    fileprivate var context: NSManagedObjectContext!
    fileprivate let operationQueue = OperationKit.OperationQueue()
    
    private typealias DataProvider = FetchedResultsDataProvider<Pokemon>
    fileprivate var dataSource: TableViewDatasource<DataProvider, PokemonsViewController, PokemonTableViewCell>!
    fileprivate var offset = 0
    
    fileprivate lazy var fetchedResultsDataProvider: FetchedResultsDataProvider<Pokemon> = {
        let fetchedResultsController = NSFetchedResultsController<Pokemon>(fetchRequest: Pokemon.sortedFetchRequest,
                                                                             managedObjectContext: self.context,
                                                                             sectionNameKeyPath: nil,
                                                                             cacheName: nil)
        
        return FetchedResultsDataProvider(fetchedResultsController: fetchedResultsController)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Pokemons"
        
        configureTableView()
        getPokemons()
        dataSource = TableViewDatasource(tableView: tableView, fetchedResultsDataProvider: fetchedResultsDataProvider, delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Initialization
    
    required init(context: NSManagedObjectContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private methods
    
    private final func configureTableView() {
        tableView.estimatedRowHeight = 105
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(PokemonTableViewCell.self, forCellReuseIdentifier: PokemonTableViewCell.identifier)
    }
    
    fileprivate final func getPokemons(userInitiated: Bool = false) {
        let getPokemonsOperation = GetPokemonsOperation(context: context, limit: paginationLimit, offset: offset)
        getPokemonsOperation.userInitiated = true
        
        if fetchedResultsDataProvider.fetchedObjects?.isEmpty == true || userInitiated {
            getPokemonsOperation.addObserver(LoadingIndicatorObserver())
        }
        
        operationQueue.addOperation(getPokemonsOperation)
    }
}

extension PokemonsViewController: DataSourceDelegate {
    
    // MARK: DataSourceDelegate
    
    func cellIdentifier(for porkemon: Pokemon) -> String {
        return PokemonTableViewCell.identifier
    }
    
    func datasourceDidUpdate() { }
}

extension PokemonsViewController: UITableViewDelegate {
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == fetchedResultsDataProvider.fetchedObjects!.count - 1 else { return }
        
        getPokemons(userInitiated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pokemon = fetchedResultsDataProvider.object(at: indexPath)
        let pokemonDetailViewController = PokemonDetailViewController(context: context, pokemon: pokemon)
        navigationController?.pushViewController(pokemonDetailViewController, animated: true)
    }
}
