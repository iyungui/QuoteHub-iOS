//
//  DraftStory.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import Foundation
import SwiftData

@Model
class DraftStory {
    var bookId: String
    var bookTitle: String
    var bookAuthor: String
    var bookImageURL: String
    var keywords: [String]
    var quote: String
    var content: String
    var isPublic: Bool
    var themeIds: [String]
    var imageData: [Data]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        bookId: String,
        bookTitle: String,
        bookAuthor: String = "",
        bookImageURL: String = "",
        keywords: [String] = [],
        quote: String = "",
        content: String = "",
        isPublic: Bool = true,
        themeIds: [String] = [],
        imageData: [Data] = []
    ) {
        self.bookId = bookId
        self.bookTitle = bookTitle
        self.bookAuthor = bookAuthor
        self.bookImageURL = bookImageURL
        self.keywords = keywords
        self.quote = quote
        self.content = content
        self.isPublic = isPublic
        self.themeIds = themeIds
        self.imageData = imageData
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // 편의 메서드: Book 객체로부터 DraftStory 생성
    convenience init(from book: Book) {
        self.init(
            bookId: book.id,
            bookTitle: book.title,
            bookAuthor: book.author.joined(separator: ", "),
            bookImageURL: book.bookImageURL
        )
    }
    
    // 빈 상태인지 확인
    var isEmpty: Bool {
        return keywords.isEmpty &&
               quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               imageData.isEmpty
    }
    
    // 유효한 데이터인지 확인 (최소 조건)
    var isValid: Bool {
        return !keywords.isEmpty ||
               !quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
               !imageData.isEmpty
    }
}
