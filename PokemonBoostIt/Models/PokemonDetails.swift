//
//  PokemonDetails.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import Foundation

struct PokemonDetails: Equatable, Hashable {
    let abilities: [Ability]
    let forms: [Species]
    let baseExperience: Int
    let cries: Cries
    let order: Int
    let weight: Int
}


