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
    
    public static var liveValue: Self {
        let player = AVPlayer()
        
        let currentItemPublisher = player
            .currentItemPublisher()
            .compactMap { $0 }
        
        return Self(
            play: { url in
                if player.currentItem?.url != url {
                    player.replaceCurrentItem(with: AVPlayerItem(asset: AVAsset(url: url)))
                }
                
                await player.play()
            }, pause: {
                await player.pause()
            }, setRate: { rate in
                await MainActor.run {
                    player.rate = rate
                }
            }, seekTime: { seconds in
                await player.seek(to: CMTime(seconds: seconds))
            }, progress: {
                return player.playheadProgressPublisher().values.eraseToStream()
            }, status: {
                let status = currentItemPublisher
                    .flatMap { $0.statusPublisher().eraseToAnyPublisher() }
                    .map { AudioPlayerClient.Status($0) }
                    .receive(on: DispatchQueue.main)
                    .values
                    .eraseToStream()
                
                return status
            }, rate: {
                return player.ratePublisher()
                    .receive(on: DispatchQueue.main)
                    .values
                    .eraseToStream()
            }, duration: {
                let duration = currentItemPublisher
                    .flatMap { $0.durationPublisher().eraseToAnyPublisher() }
                    .map { $0.seconds }
                    .receive(on: DispatchQueue.main)
                    .values
                    .eraseToStream()
                
                return duration
            }, didPlayToEndTime: {
                let didPlayToEndTime = currentItemPublisher
                    .flatMap { $0.didPlayToEndTimePublisher().eraseToAnyPublisher() }
                    .receive(on: DispatchQueue.main)
                    .values
                    .eraseToStream()
                
                return didPlayToEndTime
            }, error: {
                let error = currentItemPublisher
                    .flatMap { $0.publisher(for: \.error).eraseToAnyPublisher() }
                    .compactMap { $0 }
                    .map { Error($0) }
                    .receive(on: DispatchQueue.main)
                    .values
                    .eraseToStream()
                
                return error
            }
        )
    }
}
