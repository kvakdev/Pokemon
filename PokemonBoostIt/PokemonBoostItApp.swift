//
//  PokemonBoostItApp.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct PokemonBoostItApp: App {
    @State var store = Store(initialState: PokemonListFeature.State.init(), reducer: { PokemonListFeature() })
    
    var body: some Scene {
        WindowGroup {
            PokemonListView(store: store)
        }
    }
}
