//
//  AVPlayerItem+Extension.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import Combine
import AVKit

extension AVPlayerItem {
    
    func isPlaybackLikelyToKeepUpPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.isPlaybackLikelyToKeepUp).eraseToAnyPublisher()
    }
    
    func isPlaybackBufferEmptyPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.isPlaybackBufferEmpty).eraseToAnyPublisher()
    }
    
    func statusPublisher() -> AnyPublisher<AVPlayerItem.Status, Never> {
        publisher(for: \.status).eraseToAnyPublisher()
    }
    
    func durationPublisher() -> AnyPublisher<CMTime, Never> {
        publisher(for: \.duration).eraseToAnyPublisher()
    }
    
    func didPlayToEndTimePublisher(_ notificationCenter: NotificationCenter = .default) -> AnyPublisher<Notification, Never> {
        notificationCenter
            .publisher(for: .AVPlayerItemDidPlayToEndTime, object: self)
            .eraseToAnyPublisher()
    }
}
