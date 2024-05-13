//
//  PokemonBoostItTests.swift
//  PokemonBoostItTests
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import XCTest
@testable import PokemonBoostIt
import ComposableArchitecture

final class PokemonListTests: XCTestCase {
    
    @MainActor
    func test_details_are_pushed() async {
        let store = TestStore(initialState: .init(), reducer: { PokemonListFeature() })
        let pokemon = Pokemon.samples[0]
            
        await store.send(.itemTapped(pokemon)) {
            $0.path.append(.details(.init(pokemon: pokemon)))
        }
    }
    
    @MainActor
    func test_fetch_is_trigerred_upon_onAppear() async {
        let store = TestStore(initialState: .init(), reducer: { PokemonListFeature() })
        
        await store.send(.onAppear)
        await store.receive(.loadAfter(nil), timeout: 1)
        await store.receive(.itemsLoaded(Pokemon.samples), timeout: 1) {
            $0.allModels = Pokemon.samples
        }
    }
}
