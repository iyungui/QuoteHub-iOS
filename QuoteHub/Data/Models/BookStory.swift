//
//  BookStory.swift
//  QuoteHub
//
//  Created by 이융의 on 10/15/23.
//

import Foundation
import SwiftUI

struct BookStory: Codable, Identifiable, Equatable {
    var id: String { _id }
    var _id: String
    var userId: User
    var bookId: Book
    var quote: String?
    var content: String?
    var storyImageURLs: [String]?
    var isPublic: Bool
    var createdAt: String
    var updatedAt: String
    var keywords: [String]?
    var themesIds: [String]?
    
    var createdAtDate: String {
        return String(createdAt.prefix(10))
    }
    var updatedAtDate: String {
        return String(updatedAt.prefix(10))
    }

    static func ==(lhs: BookStory, rhs: BookStory) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case userId
        case bookId
        case quote
        case content
        case storyImageURLs
        case isPublic
        case createdAt
        case updatedAt
        case keywords
        case themesIds = "folderIds"
    }
}

