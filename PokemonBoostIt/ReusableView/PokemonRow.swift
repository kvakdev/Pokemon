//
//  PokemonRow.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 13/05/2024.
//

import SwiftUI
import ComposableArchitecture

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
