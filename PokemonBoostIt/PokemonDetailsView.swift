//
//  PokemonDetailsView.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import SwiftUI
import ComposableArchitecture
import OggDecoder
import AVFoundation

struct PokemonDetailsFeature: Reducer {
    @Dependency(\.remoteDetailsClient) var client
    @Dependency(\.cryLoader) var cryClient
    @Dependency(\.audioPlayer) var player
    
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
        case cryButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [state] send in
                    do {
                        let details = try await client.fetchDetails(state.pokemon.url)
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
                
                return .none
            case .cryButtonTapped:
                let name = state.pokemon.name
                guard let latestCryUrl = URL(string: state.details?.cries.latest ?? "") else { return .none }
                return .run { send in
                    do {
                        let wavURL = try await cryClient.loadCry(remoteUrl: latestCryUrl, pokemonName: name)
                        try self.player.play(url: wavURL)
                    } catch {
                        await send(.error(error.localizedDescription))
                    }
                }
            }
        }
    }
}

struct PokemonDetailsView: View {
    let store: StoreOf<PokemonDetailsFeature>
    @State var player: AVAudioPlayer?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
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
                Text("Weight: \(details.weight)")
                Text("Order: \(details.order)")
                
                Spacer()
                
                CryButton()
                
            } else {
                ProgressView()
            }
            
            Spacer()
        }
        .task {
            store.send(.onAppear)
        }
    }
    
    @ViewBuilder
    func CryButton() -> some View {
        Button(action: {
            self.store.send(.cryButtonTapped)
        }, label: {
            Text("Tap to hear the latest cry")
        })
        .buttonBorderShape(.automatic)
        .buttonStyle(.borderedProminent)
        .padding()
    }
}

#Preview {
    let pokemon = Pokemon.samples[0]
    let store = Store(initialState: .init(details: nil, pokemon: pokemon), reducer: { PokemonDetailsFeature()
    })
    
    return PokemonDetailsView(store: store)
}



