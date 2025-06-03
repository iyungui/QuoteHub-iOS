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
    
    struct Book: Codable {
        var _id: String
        var title: String
        var author: [String]
        var translator: [String]
        var introduction: String
        var publisher: String
        var publicationDate: String
        var bookImageURL: String
        var bookLink: String
        var ISBN: [String]
    }
}

