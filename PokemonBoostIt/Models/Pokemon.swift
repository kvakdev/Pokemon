//
//  Pokemon.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import Foundation

struct Pokemon: Equatable, Hashable {
    let name: String
    let url: URL
    let imageUrl: URL
    let index: Int
}
