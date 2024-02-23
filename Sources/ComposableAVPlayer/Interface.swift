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
    
    public var play: @Sendable (_ url: URL) async -> Void
    public var pause: @Sendable () async -> Void
    public var setRate: @Sendable (_ rate: Float) async -> Void
    public var seekTime: @Sendable (_ seconds: Double) async -> Void
    
    public var progressEffect: @Sendable () -> Effect<TimeInterval> = { .none }
    public var statusEffect: @Sendable () -> Effect<Status> = { .none }
    public var rateEffect: @Sendable () -> Effect<Float> = { .none }
    public var durationEffect: @Sendable () -> Effect<Double> = { .none }
    public var didPlayToEndTimeEffect: @Sendable () -> Effect<Notification> = { .none }
    public var errorEffect: @Sendable () -> Effect<Error> = { .none }
}

extension AudioPlayerClient: TestDependencyKey {
    
    public static let previewValue = Self()
    
    public static let testValue = Self()
}

extension DependencyValues {
    
    public var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}
