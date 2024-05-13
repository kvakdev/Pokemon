//
//  PokemonMapper.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 13/05/2024.
//

import Foundation

struct PokemonMapper {
    struct PokemonResponse: Decodable {
        let count: Int
        let next: String?
        let previous: String?
        let results: [RemotePokemon]
    }
    
    struct RemotePokemon: Decodable {
        let name: String
        let url: URL
    }
    
    static func map(data: Data) throws -> [Pokemon] {
        let mapped = try JSONDecoder().decode(PokemonResponse.self, from: data)
        
        return mapped.results.map { remotePokemon in
            let index = Int(remotePokemon.url.lastPathComponent)!
            let imageUrl = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(index).png")!
            
            return Pokemon(name: remotePokemon.name, url: remotePokemon.url, imageUrl: imageUrl, index: index )
        }

    }
}
