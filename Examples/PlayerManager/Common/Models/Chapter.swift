//
//  Chapter.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import Foundation

public struct Chapter: Equatable, Identifiable {
    public let id: Int
    public let title: String
    public let playUrl: URL
}

extension Chapter {
    
    public static let dummyChapter: (_ id: Int) -> Chapter = { id in
        return Chapter(
            id: id,
            title: "Design is not how a thing looks, but how it works #\(id + 1)",
            playUrl: URL(string: "https://samples.audible.com/or/orig/00132\(id)/or_orig_00132\(id)_sample.mp3")!
        )
    }
}
