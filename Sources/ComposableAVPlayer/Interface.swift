//
//  AudioPlayerClient.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import ComposableArchitecture
import DependenciesMacros
import Foundation
import Combine

@DependencyClient
public struct AudioPlayerClient {
    
    public enum Status: Int {
        case unknown
        case readyToPlay
        case failed
    }
    
    public struct Error: Swift.Error, Equatable {
        let error: NSError
        
        public init(_ error: Swift.Error) {
            self.error = error as NSError
        }
    }
    
    public var play: (_ url: URL) async -> Void
    public var pause: () async -> Void
    public var setRate: (_ rate: Float) async -> Void
    public var seekTime: (_ seconds: Double) async -> Void
    
    public var progressEffect: () -> Effect<TimeInterval> = { .none }
    public var statusEffect: () -> Effect<Status> = { .none }
    public var rateEffect: () -> Effect<Float> = { .none }
    public var durationEffect: () -> Effect<Double> = { .none }
    public var didPlayToEndTimeEffect: () -> Effect<Notification> = { .none }
    public var errorEffect: () -> Effect<Error> = { .none }
}

extension AudioPlayerClient: TestDependencyKey {
    
    public static let previewValue = Self(
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
    
    public static let testValue = Self(
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
            unimplemented("\(Self.self).errorEffect", placeholder: Effect<Error>.none)
        }
    )
}

extension DependencyValues {
    
    public var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}
