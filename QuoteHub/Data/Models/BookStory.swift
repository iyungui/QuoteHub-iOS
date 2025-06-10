//
//  BookStory.swift
//  QuoteHub
//
//  Created by 이융의 on 10/15/23.
//

import Foundation
import SwiftUI

struct Quote: Codable {
    let quote: String
    let page: Int?
}

struct BookStory: Codable, Identifiable, Equatable {
    var id: String { _id }
    let _id: String
    let userId: User
    let bookId: Book
    let quotes: [Quote]
    let content: String?
    let storyImageURLs: [String]?
    let isPublic: Bool
    let createdAt: String
    let updatedAt: String
    let keywords: [String]?
    let themeIds: [String]?

    static func ==(lhs: BookStory, rhs: BookStory) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case userId
        case bookId
        case quotes
        case content
        case storyImageURLs
        case isPublic
        case createdAt
        case updatedAt
        case keywords
        case themeIds = "folderIds"
    }
}

extension BookStory {
    /// 첫 번째 문장 텍스트
    var firstQuoteText: String {
        if let quote = quotes.first, !quote.quote.isEmpty {
            return quote.quote
        }
        return ""
    }
    
    /// 총 문장 개수
    var quotesCount: Int { return quotes.count }
}


