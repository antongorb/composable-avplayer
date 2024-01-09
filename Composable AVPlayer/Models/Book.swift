//
//  Book.swift
//  Composable AVPlayer
//
//  Created by Anton Gorb on 08.01.2024.
//

import Foundation

struct Book: Equatable, Identifiable {
    let id: Int
    let title: String
    let imageURL: URL
    let chapters: [Chapter]
}

extension Book {
    
    static let dummyBook = Book(
        id: 1,
        title: "Book name",
        imageURL: URL(string: "https://makeheadway.com/_next/image/?url=https%3A%2F%2Fstatic.get-headway.com%2F0yVH2fZcml8mHwULbHaB-15f92c12655540.jpg&w=750&q=75")!,
        chapters: Array(repeating: 0, count: 4)
            .enumerated()
            .map { $0.0 }.map(Chapter.dummyChapter)
    )
}
