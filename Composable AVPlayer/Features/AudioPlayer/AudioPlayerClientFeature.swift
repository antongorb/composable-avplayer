//
//  AudioPlayerClientFeature.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AudioPlayerClientFeature {
    
    struct State: Equatable {
        var isPlaying = false
        
        var duration: Double = 0
        var durationSafe: Double {
            guard duration.isFinite else { return .zero }
            
            return duration
        }
        
        var rate: Float = 1
        var rateFormatted: String {
            return "Speed x\(rate)"
        }
        
        var progress: Double = 0
        var progressFormattable: String {
            return Int(progress).toHHmmSS()
        }
        
        var durationFormattable: String {
            guard duration.isFinite else { return "00:00" }
            
            return Int(duration).toHHmmSS()
        }
    }
    
    enum Action: Equatable {
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
    
    var body: some ReducerOf<Self> {
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
                AppLogger.shared.log("\(error.localizedDescription)")
                
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
                return audioPlayer.progressEffect().map { .progressUpdated($0) }
            case .startListenDuration:
                return audioPlayer.durationEffect().map { .durationUpdated($0) }
            case .startListenRate:
                return audioPlayer.rateEffect().map { .rateUpdated($0) }
            case .startListenDidPlayToEndTime:
                return audioPlayer.didPlayToEndTimeEffect().map { _ in .didPlayToEndTimeReceived }
            case .startListenError:
                return audioPlayer.errorEffect().map { .errorReceived($0) }
            }
        }
    }
}
