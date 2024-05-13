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
    typealias Item = Pokemon
    
    @ObservableState
    struct State: Equatable {
        var models: [Item] = []
        var error: String?
        
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        case itemTapped(Item)
        case onAppear
        case itemsLoaded([Item])
        case displayError(String)
        case onAppearOf(Item)
        case loadAfter(Item?)
        case retryLastLoad
        case path(StackActionOf<Path>)
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
                state.models.append(contentsOf: newItems)
                state.error = nil
                
                return .none
                
            case .displayError(let error):
                state.error = error
                
                return .none
            case .onAppearOf(let item):
                let shouldLoad = state.error == nil && state.models.count < Constants.totalNumberOfItems && item == state.models.last
                
                guard shouldLoad else { return .none }
                
                return .send(.loadAfter(item))
                
            case .retryLastLoad:
                return .send(.loadAfter(state.models.last))
                
            case .loadAfter(let item):
                if item == nil && !state.models.isEmpty { return .none }
                
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
                ForEach(store.models, id: \.self.name) { item in
                    PokemonRow(item: item, store: store)
                }
                .listRowSeparator(.hidden)
                
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

struct AsyncRefreshableImageView: View {
    let url: URL
    @State var id = UUID()
    @State var isRetryDisabled = false
    
    var body: some View {
        ZStack {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .onAppear(perform: {
                            self.isRetryDisabled = true
                        })
                case .failure(let error):
                    Image(systemName: "arrow.uturn.left.circle")
                        .onAppear(perform: {
                            self.id = UUID()
                        })
                @unknown default:
                    Image(systemName: "trash")
                        .onAppear(perform: {
                            self.id = UUID()
                        })
                }
            }
            .frame(width: 100, height: 100)
            .id(id)
        }
    }
}

struct PokemonRow: View {
    let item: Pokemon
    let store: StoreOf<PokemonListFeature>
    
    var body: some View {
        HStack {
            AsyncRefreshableImageView(url: item.imageUrl)
            
            Text(item.name.capitalized)
                .font(.largeTitle)
            
            Spacer()
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear(perform: {
            store.send(.onAppearOf(item))
        })
        .onTapGesture {
            store.send(.itemTapped(item))
        }
    }
}
