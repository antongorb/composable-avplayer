//
//  AudioPlayerView.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import SwiftUI
import ComposableArchitecture

struct AudioPlayerView: View {
    
    let store: StoreOf<AudioPlayerFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                AudioInfoSection(store: self.store)
                PlayerControlsSection(store: self.store)
                SwitchModeSection(store: self.store)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }.onAppear(perform: { store.send(.onAppear) })
    }
}

// MARK: - Audio Info Section

private struct AudioInfoSection: View {
    
    let store: StoreOf<AudioPlayerFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack (alignment: .center, spacing: 8) {
                AsyncImage(url: viewStore.book.imageURL) { image in
                    image.resizable(resizingMode: .stretch)
                } placeholder: {
                    Color.gray
                }.aspectRatio(nil, contentMode: .fit)
                    .frame(width: 260)
                    .cornerRadius(8)
                    .shadow(radius: 8)
                    .padding(.bottom, 32)
                    .padding(.top, 16)
                
                Text(viewStore.currentKeyPointText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .bold()
                    .foregroundStyle(.gray)
                    .padding(.bottom, 2)
                Text(viewStore.currentChapter.title)
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
    
    let store: StoreOf<AudioPlayerFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                HStack{
                    Text(viewStore.audioPlayerClient.progressFormattable)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                    Slider(value: viewStore.binding(get: \.sliderProgress, send: { .changeSlider($0) }), in: 0...viewStore.audioPlayerClient.durationSafe) { editing in
                        viewStore.send(.update(sliderIsEditing: editing))
                        
                        if !editing {
                            viewStore.send(.seekTime(to: viewStore.sliderValue))
                        }
                    }.onAppear {
                        let progressCircleConfig = UIImage.SymbolConfiguration(scale: .medium)
                        UISlider.appearance()
                            .setThumbImage(UIImage(systemName: "circle.fill",
                                                   withConfiguration: progressCircleConfig),
                                           for: .normal)
                    }
                    
                    Text(viewStore.audioPlayerClient.durationFormattable)
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal)
                
                Button(action: {
                    store.send(.changeRateButtonTapped)
                }, label: {
                    Text(viewStore.audioPlayerClient.rateFormatted)
                        .padding(.vertical, 3)
                        .foregroundColor(.black)
                })
                .buttonStyle(.bordered)
                .tint(.gray)
                .font(.footnote).bold()
                .foregroundColor(.black)
                .padding(.top)
                
                
                HStack{
                    Button(action: {
                        store.send(.skipToPreviousButtonTapped)
                    }) {
                        Image(systemName: "backward.end.fill")
                            .font(.system(size: 25))
                            .foregroundColor(viewStore.skipToPreviousButtonEnabled ? .black : .gray)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }.disabled(!viewStore.skipToPreviousButtonEnabled)
                    
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
                            Image(systemName: viewStore.audioPlayerClient.isPlaying ? "pause.fill" : "play.fill")
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
                            .foregroundColor(viewStore.skipToNextButtonEnabled ? .black : .gray)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }.disabled(!viewStore.skipToNextButtonEnabled)
                    
                }
                .padding(.top, 24)
                .padding(.bottom, 24)
                .padding(.horizontal, 45)
            }
        }
        
    }
}

// MARK: - Switch Mode Section

private struct SwitchModeSection: View {
    
    let store: StoreOf<AudioPlayerFeature>
    
    var body: some View {
        VStack {
            HStack {
                
                Spacer()
                
                HStack(alignment: .center, spacing: 0.0) {
                    Button(action: { }){
                        Image(systemName: "headphones")
                            .resizable()
                            .font(.system(size: 5))
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 15)
                    }
                    .font(.footnote).bold()
                    .background(.blue)
                    .clipShape(Circle())
                    .frame(width: 50, height: 50.0)
                    
                    Button(action: { }) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 14)).bold()
                            .foregroundColor(.black)
                            .frame(minWidth: 0, maxWidth: .infinity)
                    }.frame(width: 50, height: 50.0)
                    
                }.background(.white)
                    .padding(.all, 2.0)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Spacer()
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
