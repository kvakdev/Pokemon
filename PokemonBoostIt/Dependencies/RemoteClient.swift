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
        client.getPokemons = {
            [
                Pokemon(name: "ivysaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/2/")!),
                Pokemon(name: "venusaur", url: URL(string: "https://pokeapi.co/api/v2/pokemon/3/")!)
            ]
        }
        
        return client
    }()
    
    init(getPokemons: Callback? = nil) {
        self.getPokemons = getPokemons
    }
    
    func fetchPokemons() async throws -> [Pokemon] {
        if let pokemons = getPokemons?() { return pokemons }
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10")!
        
        let data = try await URLSession.shared.data(from: url)
        let mapped = try JSONDecoder().decode(PokemonResponse.self, from: data.0)
        
        return mapped.results.map { Pokemon(name: $0.name, url: $0.url) }
    }
}

extension DependencyValues {
    var remoteClient: RemoteClient {
        get { self[RemoteClient.self] }
        set { self[RemoteClient.self] = newValue }
    }
}
