//
//  AudioPlayerClient.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import ComposableArchitecture
import Foundation
import Combine

@DependencyClient
struct AudioPlayerClient {
    
    enum Status: Int {
        case unknown
        case readyToPlay
        case failed
    }
    
    var play: (_ url: URL) async -> Void
    var pause: () async -> Void
    var setRate: (_ rate: Float) async -> Void
    var seekTime: (_ seconds: Double) async -> Void
    
    var progressEffect: () -> Effect<TimeInterval> = { .none }
    var statusEffect: () -> Effect<Status> = { .none }
    var rateEffect: () -> Effect<Float> = { .none }
    var durationEffect: () -> Effect<Double> = { .none }
    var didPlayToEndTimeEffect: () -> Effect<Notification> = { .none }
    var errorEffect: () -> Effect<EquatableError> = { .none }
}

extension AudioPlayerClient: TestDependencyKey {
    
    static let previewValue = Self(
        play: { _ in
        }, pause: {
        }, setRate: { _ in
        }, seekTime: { _ in
        }, progressEffect: {
            return .none
        }, statusEffect: {
            return .none
        }, rateEffect: {
            return .none
        }, durationEffect: {
            return .none
        }, didPlayToEndTimeEffect: {
            return .none
        }, errorEffect: {
            return .none
        }
    )
    
    static let testValue = Self(
        play: { _ in
            unimplemented("\(Self.self).play")
        }, pause: {
            unimplemented("\(Self.self).pause")
        }, setRate: { _ in
            unimplemented("\(Self.self).setRate")
        }, seekTime: { _ in
            unimplemented("\(Self.self).seekTime")
        }, progressEffect: {
            unimplemented("\(Self.self).progressEffect", placeholder: Effect<TimeInterval>.none)
        }, statusEffect: {
            unimplemented("\(Self.self).statusEffect", placeholder: Effect<Status>.none)
        }, rateEffect: {
            unimplemented("\(Self.self).rateEffect", placeholder: Effect<Float>.none)
        }, durationEffect: {
            unimplemented("\(Self.self).durationEffect", placeholder: Effect<Double>.none)
        }, didPlayToEndTimeEffect: {
            unimplemented("\(Self.self).didPlayToEndTimeEffect", placeholder: Effect<Notification>.none)
        }, errorEffect: {
            unimplemented("\(Self.self).errorEffect", placeholder: Effect<EquatableError>.none)
        }
    )
}

extension DependencyValues {
    
    var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}
