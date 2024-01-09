//
//  CMTime+Extension.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 09.01.2024.
//

import Foundation
import AVKit

extension CMTime {
    
    init(seconds: Double) {
        self.init(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    }
}
