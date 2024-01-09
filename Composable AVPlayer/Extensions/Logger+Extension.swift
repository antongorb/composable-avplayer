//
//  Logger+Extension.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import OSLog

struct AppLogger {
    static let shared = AppLogger()
    
    private init() {}
    
    func log(_ message: String) {
        Logger.shared.log("\(message)")
    }
}

extension Logger {
    
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let shared = Logger(subsystem: subsystem, category: "appcycle")
}
