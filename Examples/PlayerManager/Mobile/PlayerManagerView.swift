import Combine
import ComposableArchitecture
import ComposableAVPlayer
import SwiftUI

private let readMe = """
  This application demonstrates how to work with Composable AVPlayer
  """

struct ContentView: View {
    
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
            .navigationBarTitle("Player Manager")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
