//
//  RemoteDetailsClient.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 13/05/2024.
//

import Foundation
import ComposableArchitecture

class RemoteDetailsClient: DependencyKey {
    typealias FetchCallback = (URL) async throws -> PokemonDetails
    private(set) var fetchDetails: FetchCallback = RemoteDetailsClient.fetchDetails(url:)
    
    static var liveValue: RemoteDetailsClient = RemoteDetailsClient()
    
    static var previewValue: RemoteDetailsClient = {
        var client = RemoteDetailsClient()
        client.fetchDetails = RemoteDetailsClient.fetchDetails(url:)
        
        return client
    }()
    static var testValue: RemoteDetailsClient = {
        var client = RemoteDetailsClient()
        client.fetchDetails = RemoteDetailsClient.fetchTestDetails(url:)
        
        return client
    }()

    static func fetchDetails(url: URL) async throws -> PokemonDetails {
        let data = try await URLSession.shared.data(from: url)
        return try PokemonDetailsMapper.map(data: data.0)
    }
    
    static func fetchTestDetails(url: URL) async throws -> PokemonDetails {
        let bundle = Bundle(for: RemoteClient.self)
        let fileURL = bundle.url(forResource: "Details", withExtension: nil)
        let data = try Data(contentsOf: fileURL!)
        
        return try PokemonDetailsMapper.map(data: data)
    }
}

extension DependencyValues {
    var remoteDetailsClient: RemoteDetailsClient {
        get { self[RemoteDetailsClient.self] }
        set { self[RemoteDetailsClient.self] = newValue }
    }
}
