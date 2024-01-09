//
//  LiveAudioPlayerClient.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import AVFoundation
import Dependencies
import ComposableArchitecture
import Combine

private extension AudioPlayerClient.Status {
    
    init(_ status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            self = .unknown
        case .readyToPlay:
            self = .readyToPlay
        case .failed:
            self = .failed
        @unknown default:
            self = .unknown
        }
    }
}

private extension AVPlayerItem {
    
    var url: URL? {
        return (asset as? AVURLAsset)?.url
    }
}

extension AudioPlayerClient: DependencyKey {
    
    static var liveValue: Self {
        let player = AVQueuePlayer()
        
        let currentItemPublisher = player
            .currentItemPublisher()
            .compactMap { $0 }
        
        return Self(
            play: { url in
                if player.currentItem?.url != url {
                    player.replaceCurrentItem(with: AVPlayerItem(asset: AVAsset(url: url)))
                }
                
                player.play()
            }, pause: {
                player.pause()
            }, setRate: { rate in
                player.rate = rate
            }, seekTime: { seconds in
                await player.seek(to: CMTime(seconds: seconds))
            }, progressEffect: {
                return .publisher { player.playheadProgressPublisher().receive(on: DispatchQueue.main) }
            }, statusEffect: {
                let statusPublisher = currentItemPublisher
                    .flatMap { $0.statusPublisher().eraseToAnyPublisher() }
                    .map { AudioPlayerClient.Status($0) }
                    .receive(on: DispatchQueue.main)
                
                return .publisher { statusPublisher }
            }, rateEffect: {
                return .publisher { player.ratePublisher().receive(on: DispatchQueue.main) }
            }, durationEffect: {
                let durationPublisher = currentItemPublisher
                    .flatMap { $0.durationPublisher().eraseToAnyPublisher() }
                    .map { $0.seconds }
                    .receive(on: DispatchQueue.main)
                
                return .publisher { durationPublisher }
            }, didPlayToEndTimeEffect: {
                let didPlayToEndTimePublisher = currentItemPublisher
                    .flatMap { $0.didPlayToEndTimePublisher().eraseToAnyPublisher() }
                    .receive(on: DispatchQueue.main)
                
                return .publisher { didPlayToEndTimePublisher }
            }, errorEffect: {
                let errorPublisher = currentItemPublisher
                    .flatMap { $0.publisher(for: \.error).eraseToAnyPublisher() }
                    .compactMap { $0?.toEquatableError() }
                    .receive(on: DispatchQueue.main)
                
                return .publisher { errorPublisher }
            }
        )
    }
}
