//
//  PokemonListView.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import SwiftUI
import ComposableArchitecture


struct PokemonListFeature: Reducer {
    @Dependency(\.remoteClient) var remoteClient
    typealias Item = Pokemon
    
    @ObservableState
    struct State {
        var models: [Item] = []
        var error: String = ""
    }
    
    enum Action: Equatable {
        case itemTapped(Item)
        case onAppear
        case itemsLoaded([Item])
        case displayError(String)
        case onAppearOf(Item)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            
            switch action {
            case .itemTapped(let item):
                debugPrint("item tapped: \(item.name)")
                //show details
                return .none
            case .onAppear:
                return .run { send in
                    do {
                        let items = try await remoteClient.fetchPokemons()
                        await send(.itemsLoaded(items))
                    } catch {
                        debugPrint("some error \(error)")
                    }
                }
            case .itemsLoaded(let newItems):
                state.models.append(contentsOf: newItems)
                
                return .none
            case .displayError(let error):
                state.error = error
                
                return .none
            case .onAppearOf(let item):
                guard item == state.models.last else {
                    return .none
                }
                
                return .run { [offset = state.models.last?.index] send in
                    do {
                        let newItems = try await remoteClient.fetchPokemons(offset: offset)
                        await send(.itemsLoaded(newItems))
                    } catch {
                        await send(.displayError("Fetch failed"))
                    }
                    
                }
            }
        }
    }
}


struct PokemonListView: View {
    var store: StoreOf<PokemonListFeature>
    
    var body: some View {
        List {
            if !store.error.isEmpty {
                Text(store.error)
                    .bold()
                    .foregroundStyle(.red)
            }
            
            ForEach(store.models, id: \.self.name) { item in
                HStack {
                    AsyncImage(url: item.imageUrl) { phase in
                        switch phase {
                        case .empty:
                            Image(systemName: "trash")
                        case .success(let image):
                            image.resizable()
                        case .failure(let error):
                            Image(systemName: "trash")
                        @unknown default:
                            Image(systemName: "trash")
                        }
                    }
                    .scaledToFit()
                    .frame(maxWidth: 100, maxHeight: 100)
                    
                    Text(item.name)
                        .onTapGesture {
                            store.send(.itemTapped(item))
                    }
                }
                .onAppear(perform: {
                    store.send(.onAppearOf(item))
                })
            }
            
        }
        .onAppear(perform: {
            store.send(.onAppear)
        })
    }
}

#Preview {
    PokemonListView(store: Store(initialState: .init(), reducer: {
        PokemonListFeature()
    }))
}
