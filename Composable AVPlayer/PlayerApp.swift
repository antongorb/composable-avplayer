//
//  Composable_AVPlayerApp.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct PlayerApp: App {
    
    let store: StoreOf<RootReducer>
    
    init() {
        self.store = Store(initialState: RootReducer.State()) {
            RootReducer()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                RootView(store: self.store)
            }
        }
    }
}
