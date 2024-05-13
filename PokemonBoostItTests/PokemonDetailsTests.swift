//
//  PokemonDetailsTests.swift
//  PokemonBoostItTests
//
//  Created by Andrii Kvashuk on 12/05/2024.
//

import XCTest
import ComposableArchitecture
@testable import PokemonBoostIt

final class PokemonDetailsTests: XCTestCase {

    @MainActor
    func test_onAppear_triggersLoadingOfDetails() async throws {
        let pokemon = Pokemon.samples[0]
        let store = TestStore(initialState: .init(pokemon: pokemon) , reducer: { PokemonDetailsFeature() })
        let expecteedValue = try await RemoteDetailsClient.testValue.fetchDetails(URL(string: "http://any-url.com")!)
        
        await store.send(.onAppear) {
            $0.details = expecteedValue
        }
    }
    
}
