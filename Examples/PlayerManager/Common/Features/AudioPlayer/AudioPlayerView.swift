//
//  AudioPlayerView.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import SwiftUI
import ComposableArchitecture

#if os(macOS)
    typealias UIImage = NSImage
#endif

struct AudioPlayerView: View {
    
    private let store: StoreOf<AudioPlayerFeature>
    
    init(store: StoreOf<AudioPlayerFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                AudioInfoSection(store: store)
                PlayerControlsSection(store: store)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .onAppear(perform: { store.send(.onAppear) })
        }
    }
}

// MARK: - Audio Info Section

private struct AudioInfoSection: View {
    
    private let store: StoreOf<AudioPlayerFeature>
    
    init(store: StoreOf<AudioPlayerFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack (alignment: .center, spacing: 8) {
                AsyncImage(url: store.book.imageURL) { image in
                    image.resizable(resizingMode: .stretch)
                } placeholder: {
                    Color.gray
                }.aspectRatio(nil, contentMode: .fit)
                    .frame(width: 260)
                    .cornerRadius(8)
                    .shadow(radius: 8)
                    .padding(.bottom, 32)
                    .padding(.top, 16)
                
                Text(store.currentKeyPointText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 2)
                Text(store.currentChapter.title)
                    .font(.footnote)
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.bottom, 2)
                    .padding(.horizontal, 35)
            }
            .padding([.top, .bottom])
        }
    }
}

// MARK: - Player Controls Section

private struct PlayerControlsSection: View {
    
    @Perception.Bindable private var store: StoreOf<AudioPlayerFeature>
    
    init(store: StoreOf<AudioPlayerFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithPerceptionTracking {
            VStack {
                HStack{
                    Text(store.audioPlayerClient.progressFormattable)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    Slider(value: $store.sliderProgress.sending(\.changeSlider), in: 0...store.audioPlayerClient.durationSafe) { editing in
                        store.send(.update(sliderIsEditing: editing))
                        
                        if !editing {
                            store.send(.seekTime(to: store.sliderValue))
                        }
                    }
                    
                    Text(store.audioPlayerClient.durationFormattable)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal)
                
                Button(action: {
                    store.send(.changeRateButtonTapped)
                }, label: {
                    Text(store.audioPlayerClient.rateFormatted)
                        .padding(.vertical, 3)
                        .foregroundColor(.black)
                })
                .buttonStyle(.bordered)
                .tint(.gray)
                .font(.footnote)
                .foregroundColor(.black)
                .padding(.top)
                
                
                HStack{
                    Button(action: {
                        store.send(.skipToPreviousButtonTapped)
                    }) {
                        Image(systemName: "backward.end.fill")
                            .font(.system(size: 25))
                            .foregroundColor(store.skipToPreviousButtonEnabled ? .black : .gray)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }.disabled(!store.skipToPreviousButtonEnabled)
                    
                    Button(action: {
                        store.send(.skipBackwardButtonTapped)
                    }) {
                        Image(systemName: "gobackward.5")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        store.send(.playButtonTapped)
                    }) {
                        ZStack{
                            Image(systemName: store.audioPlayerClient.isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(.black)
                                .font(.system(size: 40))
                                .frame(width: 80, height: 80)
                        }
                        .shadow(radius: 16)
                    }
                    
                    Button(action: {
                        store.send(.skipForwardButtonTapped)
                    }) {
                        Image(systemName: "goforward.10")
                            .font(.system(size: 30))
                            .foregroundColor(.black)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        store.send(.skipToNextButtonTapped)
                    }) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 25))
                            .foregroundColor(store.skipToNextButtonEnabled ? .black : .gray)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }.disabled(!store.skipToNextButtonEnabled)
                    
                }
                .padding(.top, 24)
                .padding(.bottom, 24)
                .padding(.horizontal, 45)
            }
        }
    }
}

// MARK: - Previews

struct AudioPlayerView_Previews: PreviewProvider {
    
    static var previews: some View {
        let store = Store(
            initialState: AudioPlayerFeature.State(
                book: Book.dummyBook,
                currentChapter: Book.dummyBook.chapters.first!
            )
        ) {
            AudioPlayerFeature()
        }
        
        AudioPlayerView(store: store)
    }
}
