//
//  PokemonDetailViewController.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 TPaga. All rights reserved.
//

import CoreData
import OperationKit
import SDWebImage
import UIKit

class PokemonDetailViewController: UIViewController {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var nationalIdLabel: UILabel!
    @IBOutlet fileprivate var pictureImageView: UIImageView!
    @IBOutlet private var ratioLabel: UILabel!
    
    fileprivate var context: NSManagedObjectContext!
    private var contextObserver: ContextObserver!
    private let operationQueue = OperationKit.OperationQueue()
    fileprivate var pokemon: Pokemon! {
        didSet {
            loadPokemonImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = pokemon.name.capitalized
        
        contextObserver = ContextObserver(context: context, entityName: Pokemon.entityName, predicate: NSPredicate(format: "id == %i", pokemon.id))
        contextObserver.delegate = self
        
        nameLabel.text = pokemon.name.capitalized
        nationalIdLabel.text = "National Id: \(pokemon.id)"
        ratioLabel.text = "Ratio: \(pokemon.ratio.capitalized)"
        getSprites()
        loadPokemonImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK: Initialization
    
    required init(context: NSManagedObjectContext, pokemon: Pokemon) {
        self.context = context
        self.pokemon = pokemon
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private methods
    
    private final func getSprites() {
        for resourceUri in pokemon.sprites {
            let getSpriteOperation = GetSpritesOperation(context: context, path: resourceUri, pokemonId: pokemon.id)
            getSpriteOperation.userInitiated = true
            operationQueue.addOperation(getSpriteOperation)
        }
    }
    
    private final func loadPokemonImage() {
        guard let path = pokemon.imagesStringURLS.first else { return }
        
        let url = Server.current.url.appendingPathComponent(path)
        pictureImageView.sd_setImage(with: url)
    }
}

extension PokemonDetailViewController: ManagedObjectContextObservable {
    
    // MARK: ManagedObjectContextObservable
    
    func managedObjectContext(_ context: NSManagedObjectContext, didUpdate update: [String: [NSManagedObject]]) {
        guard pictureImageView.image == nil else { return }
        
        self.context.perform {
            guard let pokemon = Pokemon.findOrFetch(in: self.context, matchingPredicate: NSPredicate(format: "id == %i", self.pokemon.id)) else { return }
            
            self.pokemon = pokemon
        }
    }
}
