//
//  PokemonListView.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 08/05/2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct PokemonListFeature {
    @Dependency(\.remoteClient) var remoteClient
    
    @ObservableState
    struct State: Equatable {
        var allModels: [Pokemon] = []
        var filteredModels: [Pokemon] = []
        var error: String?
        var noResultsMessage: String?
        var query = ""
        var isLoading = false
        
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        case itemTapped(Pokemon)
        case onAppear
        case itemsLoaded([Pokemon])
        case displayError(String)
        case onAppearOf(Pokemon)
        case loadAfter(Pokemon?)
        case retryLastLoad
        case path(StackActionOf<Path>)
        case searchQueryChanged(String)
        case filterQuery
    }
    
    enum Constants {
        static let totalNumberOfItems = 1302
    }
    
    @Reducer(state: .equatable, action: .equatable)
    enum Path {
        case details(PokemonDetailsFeature)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            
            switch action {
            case .itemTapped(let item):
                //show details
                state.path.append(.details(PokemonDetailsFeature.State(pokemon: item)))
                return .none
                
            case .onAppear:
                return .send(.loadAfter(nil))
                
            case .itemsLoaded(let newItems):
                state.allModels.append(contentsOf: newItems)
                state.error = nil
                state.isLoading = false
                
                return .send(.filterQuery)
                
            case .displayError(let error):
                state.error = error
                state.isLoading = false
                
                return .none
                
            case .onAppearOf(let item):
                let shouldLoad = state.error == nil && state.allModels.count < Constants.totalNumberOfItems && item == state.allModels.last
                
                guard shouldLoad else { return .none }
                
                return .send(.loadAfter(item))
                
            case .retryLastLoad:
                return .send(.loadAfter(state.allModels.last))
                
            case .loadAfter(let item):
                if item == nil && !state.allModels.isEmpty { return .none }
                state.isLoading = true
                
                return .run { [offset = item?.index ?? 0] send in
                    do {
                        let newItems = try await remoteClient.fetchPokemons(offset)
                        await send(.itemsLoaded(newItems))
                    } catch {
                        await send(.displayError("Load failed please tap to try again"))
                    }
                }
            case .path(_):
                return .none
            case .searchQueryChanged(let query):
                state.query = query
                
                return .send(.filterQuery)
                
            case .filterQuery:
                guard !state.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    state.filteredModels = state.allModels
                    
                
                    return .none
                }
                
                let lowercasedQuery = state.query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                state.filteredModels = state.allModels.filter { $0.name.lowercased().contains(lowercasedQuery) }
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}


struct PokemonListView: View {
    @Bindable var store: StoreOf<PokemonListFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField(text: $store.query.sending(\.searchQueryChanged)) {
                        Text("Search:")
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top)
                
                ForEach(store.filteredModels, id: \.self.name) { item in
                    PokemonRow(item: item, store: store)
                }
                .listRowSeparator(.hidden)
                
                if store.isLoading {
                    ProgressView()
                        .foregroundStyle(.orange)
                }
                
                if let error = store.error {
                    Button(action: {
                        store.send(.retryLastLoad)
                    }, label: {
                        Text(error)
                            .bold()
                            .foregroundStyle(.red)
                    })
                }
            }
            .task {
                store.send(.onAppear)
            }
        } destination: { store in
            switch store.case {
            case .details(let store):
                PokemonDetailsView(store: store)
            }
        }

        
    }
}

#Preview {
    PokemonListView(store: Store(initialState: .init(), reducer: {
        PokemonListFeature()
    }))
}
