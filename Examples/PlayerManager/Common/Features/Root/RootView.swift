//
//  RootView.swift
//  PlayerManager
//
//  Created by Anton Gorb on 07.02.2024.
//  Copyright © 2024 Brandon Williams. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

private let readMe = """
  This application demonstrates how to work with Composable AVPlayer
  """

struct RootView: View {
    
    var body: some View {
        NavigationView {
            Form {
                Section(
                    header: Text(readMe)
                        .font(.caption)
                        .padding([.bottom])
                ) {
                    NavigationLink(
                        "Go to demo",
                        destination: AudioPlayerView(store: Store(initialState: AudioPlayerFeature.State(book: Book.dummyBook, currentChapter: Chapter.dummyChapter(1)), reducer: { AudioPlayerFeature() }))
                    )
                }
            }
            .navigationTitle("Player Manager")
        }
    }
}
