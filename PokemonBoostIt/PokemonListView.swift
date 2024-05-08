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
            .listRowSeparator(.hidden)
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
                        .onAppear(perform: {
                            self.isRetryDisabled = false
                        })
                case .success(let image):
                    image.resizable()
                        .onAppear(perform: {
                            self.isRetryDisabled = true
                        })
                case .failure(let error):
                    Image(systemName: "arrow.uturn.left.circle")
                        .onAppear(perform: {
                            self.isRetryDisabled = false
                        })
                @unknown default:
                    Image(systemName: "trash")
                        .onAppear(perform: {
                            self.isRetryDisabled = false
                        })
                }
            }
            .frame(width: 100, height: 100)
            .id(id)
            
            Button(action: {
                self.id = UUID()
            }, label: {
                Color.black.opacity(0.001)
            })
            .frame(width: 100, height: 100)
            .disabled(isRetryDisabled)
        }
    }
}
