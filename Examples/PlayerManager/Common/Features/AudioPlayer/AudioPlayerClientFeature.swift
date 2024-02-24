//
//  AudioPlayerClientFeature.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import Foundation
import ComposableArchitecture
import ComposableAVPlayer

@Reducer
public struct AudioPlayerClientFeature {
    
    @ObservableState
    public struct State: Equatable {
        public var isPlaying = false
        
        public var duration: Double = 0
        public var durationSafe: Double {
            guard duration.isFinite else { return .zero }
            
            return duration
        }
        
        public var rate: Float = 1
        public var rateFormatted: String {
            return "Speed x\(rate)"
        }
        
        public var progress: Double = 0
        public var progressFormattable: String {
            return Int(progress).toHHmmSS()
        }
        
        public var durationFormattable: String {
            guard duration.isFinite else { return "00:00" }
            
            return Int(duration).toHHmmSS()
        }
        
        public init(isPlaying: Bool = false, duration: Double = 0, rate: Float = 1, progress: Double = 0) {
            self.isPlaying = isPlaying
            self.duration = duration
            self.rate = rate
            self.progress = progress
        }
    }
    
    public enum Action: Equatable {
        case play(url: URL)
        case pause
        case update(rate: Float)
        case seek(time: Double)
        case skipForward(seconds: Double)
        case skipBackward(seconds: Double)
        case skipToNext(url: URL)
        case skipToPrevious(url: URL)
        case progressUpdated(TimeInterval)
        case durationUpdated(Double)
        case rateUpdated(Float)
        case errorReceived(AudioPlayerClient.Error)
        case didPlayToEndTimeReceived
        case changeSlider(Double)
        case startObserving
        case startListenProgress
        case startListenDuration
        case startListenRate
        case startListenDidPlayToEndTime
        case startListenError
    }
    
    @Dependency(\.audioPlayer) var audioPlayer
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .play(let url):
                state.isPlaying = true
                let rate = state.rate
                
                return .run { send in
                    await send(.update(rate: rate))
                    await audioPlayer.play(url)
                }
            case .pause:
                state.isPlaying = false
                
                return .run { send in
                    await audioPlayer.pause()
                }
            case .update(let rate):
                state.rate = rate
                
                if !state.isPlaying {
                    return .none
                }
                
                return .run { send in
                    await audioPlayer.setRate(rate: rate)
                }
            case .seek(let progress):
                state.progress = progress
                
                return .run { send in
                    await audioPlayer.seekTime(seconds: progress)
                }
            case .skipForward(let seconds):
                let seconds = min(state.progress + seconds, state.duration)
                
                return .send(.seek(time: seconds))
            case .skipBackward(let seconds):
                let seconds = max(state.progress - seconds, 0)
                
                return .send(.seek(time: seconds))
            case .skipToNext(let url):
                let action = Action.update(rate: state.rate)
                
                return .run { send in
                    await audioPlayer.play(url)
                    await send(action)
                }
            case .skipToPrevious(let url):
                let action = Action.update(rate: state.rate)
                
                return .run { send in
                    await audioPlayer.play(url)
                    await send(action)
                }
            case .progressUpdated(let time):
                state.progress = time
                
                return .none
            case .durationUpdated(let duration):
                state.duration = duration
                
                return .none
            case .rateUpdated(let rate):
                state.isPlaying = !rate.isZero
                
                return .none
            case .didPlayToEndTimeReceived:
                return .none
            case .errorReceived(let error):
                print(error.localizedDescription)
                
                return .none
            case .changeSlider(let value):
                state.progress = value
                
                return .none
            case .startObserving:
                return .run { send in
                    await send(.startListenProgress)
                    await send(.startListenDuration)
                    await send(.startListenRate)
                    await send(.startListenDidPlayToEndTime)
                    await send(.startListenError)
                }
            case .startListenProgress:
                return .run { send in
                    for await progress in await self.audioPlayer.progress() {
                        await send(.progressUpdated(progress))
                    }
                }
            case .startListenDuration:
                return .run { send in
                    for await duration in await self.audioPlayer.duration() {
                        await send(.durationUpdated(duration))
                    }
                }
            case .startListenRate:
                return .run { send in
                    for await rate in await self.audioPlayer.rate() {
                        await send(.rateUpdated(rate))
                    }
                }
            case .startListenDidPlayToEndTime:
                return .run { send in
                    for await _ in await self.audioPlayer.didPlayToEndTime() {
                        await send(.didPlayToEndTimeReceived)
                    }
                }
            case .startListenError:
                return .run { send in
                    for await error in await self.audioPlayer.error() {
                        await send(.errorReceived(error))
                    }
                }
            }
        }
    }
}
