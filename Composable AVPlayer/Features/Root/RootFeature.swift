//
//  RootFeature.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import Foundation
import ComposableArchitecture

struct RootReducer: Reducer {
    
    struct State: Equatable {
        var audioPlayer = AudioPlayerFeature.State(
            book: Book.dummyBook,
            currentChapter: Book.dummyBook.chapters.first!
        )
    }
    
    enum Action {
        case audioPlayer(AudioPlayerFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.audioPlayer, action: /Action.audioPlayer) {
            AudioPlayerFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .audioPlayer(_):
                return .none
            }
        }
    }
}
