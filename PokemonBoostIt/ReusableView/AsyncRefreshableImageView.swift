//
//  AsyncRefreshableImageView.swift
//  PokemonBoostIt
//
//  Created by Andrii Kvashuk on 13/05/2024.
//

import SwiftUI


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
                case .failure:
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
