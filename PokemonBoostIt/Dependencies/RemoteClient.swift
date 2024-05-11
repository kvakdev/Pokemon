//
//  RemoteClient.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import Foundation
import ComposableArchitecture

class RemoteClient: DependencyKey {
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

    
    typealias Callback = () -> [Pokemon]
    private(set) var getPokemons: Callback?
    
    static var liveValue: RemoteClient = RemoteClient()
    static var previewValue: RemoteClient = {
        var client = RemoteClient()
        client.getPokemons = { Pokemon.samples }
        
        return client
    }()
    
    init(getPokemons: Callback? = nil) {
        self.getPokemons = getPokemons
    }
    
    func fetchPokemons(offset: Int? = 0) async throws -> [Pokemon] {
        if let pokemons = getPokemons?() { return pokemons }
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10&offset=\(offset ?? 0)")!
        
        let data = try await URLSession.shared.data(from: url)
        let mapped = try JSONDecoder().decode(PokemonResponse.self, from: data.0)
        
        return mapped.results.map { remotePokemon in
            let index = Int(remotePokemon.url.lastPathComponent)!
            let imageUrl = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(index).png")!
            
            return Pokemon(name: remotePokemon.name, url: remotePokemon.url, imageUrl: imageUrl, index: index )
        }
    }
    
    func fetchDetails(url: URL) async throws -> PokemonDetails {
        let data = try await URLSession.shared.data(from: url)
        let mapped = try JSONDecoder().decode(RemotePokemonDetails.self, from: data.0)
        
        return PokemonDetails(abilities: mapped.abilities, forms: mapped.forms, baseExperience: mapped.baseExperience, cries: mapped.cries)
    }
}

extension DependencyValues {
    var remoteClient: RemoteClient {
        get { self[RemoteClient.self] }
        set { self[RemoteClient.self] = newValue }
    }
}
