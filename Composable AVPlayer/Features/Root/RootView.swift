//
//  RootView.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    
    let store: StoreOf<RootReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ContentView(store: self.store)
        }
    }
}

private struct ContentView: View {
    
    let store: StoreOf<RootReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            AudioPlayerView(
                store: store.scope(
                    state: \.audioPlayer,
                    action: RootReducer.Action.audioPlayer
                )
            ).background(Color(red: 1.001, green: 0.972, blue: 0.955))
        }
    }
}


// MARK: - Previews

struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        let store = Store(initialState: RootReducer.State()) {
            RootReducer()
        }
        
        RootView(store: store)
    }
}
