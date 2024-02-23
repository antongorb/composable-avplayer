//
//  AudioPlayerFeature.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import Foundation
import AVFoundation
import ComposableArchitecture

@Reducer
public struct AudioPlayerFeature {
    
    public init() { }
    
    @ObservableState
    public struct State: Equatable {
        public var book: Book
        public var currentChapter: Chapter
        
        public var sliderIsEditing: Bool = false
        public var sliderValue: Double = 0.0
        public var sliderProgress: Double {
            return sliderIsEditing ? sliderValue : audioPlayerClient.progress
        }
        
        public var skipToPreviousButtonEnabled: Bool {
            if book.chapters.firstIndex(of: currentChapter) == book.chapters.startIndex {
                return false
            } else {
                return true
            }
        }
        
        public var skipToNextButtonEnabled: Bool {
            if book.chapters.firstIndex(of: currentChapter) != book.chapters.endIndex - 1 {
                return true
            } else {
                return false
            }
        }
        
        public var currentKeyPointText: String {
            let index = book.chapters.firstIndex(of: currentChapter) ?? 0
            
            return "KEY POINT \(index + 1) OF \(book.chapters.count)"
        }
        
        public var audioPlayerClient = AudioPlayerClientFeature.State()
        
        public init(book: Book, currentChapter: Chapter, sliderIsEditing: Bool = false, sliderValue: Double = 0.0, audioPlayerClient: AudioPlayerClientFeature.State = .init()) {
            self.book = book
            self.currentChapter = currentChapter
            self.sliderIsEditing = sliderIsEditing
            self.sliderValue = sliderValue
            self.audioPlayerClient = audioPlayerClient
        }
    }
    
    public enum Action: Equatable {
        case onAppear
        case changeRateButtonTapped
        case skipToPreviousButtonTapped
        case skipToNextButtonTapped
        case skipBackwardButtonTapped
        case skipForwardButtonTapped
        case playButtonTapped
        case seekTime(to: Double)
        case update(sliderIsEditing: Bool)
        case changeSlider(Double)
        
        case audioPlayerClient(AudioPlayerClientFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.audioPlayerClient, action: /Action.audioPlayerClient) {
            AudioPlayerClientFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .changeRateButtonTapped:
                let rate = state.audioPlayerClient.rate >= 2.0
                    ? 0.5
                    : state.audioPlayerClient.rate + 0.25
                
                return .send(.audioPlayerClient(.update(rate: rate)))
            case .onAppear:
                return .merge(
                    .send(.audioPlayerClient(.startObserving)),
                    .send(.playButtonTapped)
                )
            case .skipToPreviousButtonTapped:
                guard let currIndex = state.book.chapters.firstIndex(of: state.currentChapter), currIndex > state.book.chapters.startIndex else {
                    return .none
                }
                
                let index = state.book.chapters.index(before: currIndex)
                let chapter = state.book.chapters[index]
                state.currentChapter = chapter
                
                return .send(.audioPlayerClient(.skipToPrevious(url: state.currentChapter.playUrl)))
            case .skipToNextButtonTapped:
                guard let currIndex = state.book.chapters.firstIndex(of: state.currentChapter), currIndex < state.book.chapters.endIndex - 1 else {
                    return .none
                }
                
                let index = state.book.chapters.index(after: currIndex)
                let chapter = state.book.chapters[index]
                state.currentChapter = chapter
                
                return .send(.audioPlayerClient(.skipToNext(url: state.currentChapter.playUrl)))
            case .skipBackwardButtonTapped:
                return .send(.audioPlayerClient(.skipBackward(seconds: 5)))
            case .skipForwardButtonTapped:
                return .send(.audioPlayerClient(.skipForward(seconds: 10)))
            case .playButtonTapped:
                let url = state.currentChapter.playUrl
                                
                let actions: [Effect<Action>] = [
                    .send(
                        state.audioPlayerClient.isPlaying
                        ? .audioPlayerClient(.pause)
                        : .audioPlayerClient(.play(url: url))
                    )
                ]
                
                return .merge(actions)
            case .seekTime(let time):
                return .send(.audioPlayerClient(.seek(time: time)))
            case .update(let sliderIsEditing):
                state.sliderIsEditing = sliderIsEditing
                
                return .none
            case .changeSlider(let value):
                state.sliderValue = value
                
                return .none
            case .audioPlayerClient(let action):
                switch action {
                case .didPlayToEndTimeReceived:
                    return .send(.skipToNextButtonTapped)
                default:
                    return .none
                }
            }
        }
    }
}
