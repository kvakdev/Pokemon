//
//  RemoteClient.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import Foundation
import ComposableArchitecture

class RemoteClient: DependencyKey {
    typealias FetchCallback = (Int?) async throws -> [Pokemon]
    private(set) var fetchPokemons: FetchCallback = RemoteClient.fetchPokemons(offset:)
    
    static var liveValue: RemoteClient =  RemoteClient()
    
    static var previewValue: RemoteClient = {
        var client = RemoteClient()
        client.fetchPokemons = { _ in Pokemon.samples }
        
        return client
    }()
    static var testValue: RemoteClient = {
        var client = RemoteClient()
        client.fetchPokemons = { _ in Pokemon.samples }
        
        return client
    }()
    
    private static func fetchPokemons(offset: Int? = 0) async throws -> [Pokemon] {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10&offset=\(offset ?? 0)")!
        let data = try await URLSession.shared.data(from: url)
        
        return try PokemonMapper.map(data: data.0)
    }
    
    func fetchDetails(url: URL) async throws -> PokemonDetails {
        let data = try await URLSession.shared.data(from: url)
        return try PokemonDetailsMapper.map(data: data.0)
    }
}

extension DependencyValues {
    var remoteClient: RemoteClient {
        get { self[RemoteClient.self] }
        set { self[RemoteClient.self] = newValue }
    }
}

