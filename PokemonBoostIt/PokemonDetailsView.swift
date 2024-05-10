//
//  PokemonDetailsView.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import SwiftUI
import ComposableArchitecture

struct PokemonDetailsFeature: Reducer {
    @Dependency(\.remoteClient) var client
    
    @ObservableState
    struct State: Equatable, Hashable {
        var details: PokemonDetails?
        let pokemon: Pokemon
        var error: String?
    }
    enum Action: Equatable, Hashable {
        case onAppear
        case detailsLoaded(PokemonDetails)
        case error(String)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [state] send in
                    do {
                        let details = try await client.fetchDetails(url: state.pokemon.url)
                        await send(.detailsLoaded(details))
                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }
            case .error(let error):
                state.error = error
                
                return .none
            case .detailsLoaded(let details):
                state.details = details
                
                
            }
            
            return .none
        }
    }
}

struct PokemonDetailsView: View {
    let store: StoreOf<PokemonDetailsFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            AsyncRefreshableImageView(url: store.pokemon.imageUrl)
                .padding(16)
                .background(Color.orange.opacity(0.3))
                .clipShape(.circle)
                
            
            Text(store.pokemon.name.capitalized)
                .font(.largeTitle)
            
            if let details = store.details {
                Text("Abilities:")
                ForEach(details.abilities, id: \.self.ability.name) { item in
                    Text(item.ability.name.capitalized)
                }
                Text("Base experience: \(details.baseExperience)")
            } else {
                ProgressView()
            }
            
            Spacer()
        }
        .task {
            store.send(.onAppear)
        }
    }
}

#Preview {
    let pokemon = Pokemon.samples[0]
    let store = Store(initialState: .init(details: nil, pokemon: pokemon), reducer: { PokemonDetailsFeature() })
    
    return PokemonDetailsView(store: store)
}
