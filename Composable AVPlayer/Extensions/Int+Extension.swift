//
//  Int+Extension.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import Foundation

extension Int {
    
    func toHHmmSS() -> String {
        var minute = self / 60
        let seconds = self - minute * 60
        
        if minute >= 60 {
            let hour = minute / 60
            minute = minute - hour * 60
            return "\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", seconds)))"
        }
        
        return "\(String(format: "%02d", minute)):\(String(format: "%02d", seconds))"
    }
}
