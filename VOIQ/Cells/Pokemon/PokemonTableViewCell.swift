//
//  PokemonTableViewCell.swift
//  VOIQ
//
//  Created by Jorge Orjuela on 10/18/16.
//  Copyright © 2016 VOIQ. All rights reserved.
//

import UIKit

class PokemonTableViewCell: UITableViewCell {
    
    // ConfigurableCell
    static var identifier: String { return "PokemonTableViewCellIdentifier" }
}

extension PokemonTableViewCell: ConfigurableCell {
    
    // MARK: ConfigurableCell
    
    func configure(for pokemon: Pokemon) {
        textLabel?.text = pokemon.name.capitalized
    }
}
