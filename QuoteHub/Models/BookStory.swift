//
//  BookStory.swift
//  QuoteHub
//
//  Created by 이융의 on 10/15/23.
//

import Foundation
import SwiftUI

struct Quote: Codable, Identifiable {
    let id: UUID
    var quote: String
    var page: Int?
    
    init(id: UUID = UUID(), quote: String, page: Int?) {
        self.id = id
        self.quote = quote
        self.page = page
    }
    
    // 백엔드와의 호환성을 위해 id는 인코딩/디코딩에서 제외
    enum CodingKeys: String, CodingKey {
        case quote
        case page
    }
    
    // 디코딩 시 새로운 UUID 생성
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.quote = try container.decode(String.self, forKey: .quote)
        self.page = try container.decodeIfPresent(Int.self, forKey: .page)
    }
    
    // 인코딩 시 id 제외
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quote, forKey: .quote)
        try container.encodeIfPresent(page, forKey: .page)
    }
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


