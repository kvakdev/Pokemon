//
//  PokemonDetailsView.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import SwiftUI
import ComposableArchitecture

struct PokemonDetailsFeature: Reducer {

    @ObservableState
    struct State: Equatable, Hashable {
        var details: PokemonDetails
        let pokemon: Pokemon
    }
    enum Action: Equatable, Hashable {}
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}

struct PokemonDetailsView: View {
    let store: StoreOf<PokemonDetailsFeature>
    
    var body: some View {
        VStack {
            AsyncRefreshableImageView(url: store.pokemon.imageUrl)
            
            Text(store.pokemon.name.capitalized)
                .font(.largeTitle)
        }
    }
}

#Preview {
    let pokemon = Pokemon.samples[0]
    let store = Store(initialState: .init(details: PokemonDetails(), pokemon: pokemon), reducer: { PokemonDetailsFeature() })
    
    return PokemonDetailsView(store: store)
}
