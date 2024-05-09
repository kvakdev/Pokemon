//
//  Pokemon+SampleData.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 09/05/2024.
//

import Foundation

extension Pokemon {
    static let samples = [
        Pokemon(name: "ivysaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/2/")!, imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png")!, index: 2),
        Pokemon(name: "venusaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/3/")!, imageUrl: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png")!, index: 3)
    ]
}
