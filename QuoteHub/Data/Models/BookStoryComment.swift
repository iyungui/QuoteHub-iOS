//
//  BookStoryComment.swift
//  QuoteHub
//
//  Created by 이융의 on 10/15/23.
//

import Foundation

struct BookStoryComment: Codable, Identifiable, Equatable {
    var id: String { _id }
    var _id: String
    var userId: User
    var bookStoryId: String
    var content: String
    var parentCommentId: String?
    var createdAt: String
    var updatedAt: String
    
    var createdAtDate: String {
        return String(createdAt.prefix(10))
    }
    var updatedAtDate: String {
        return String(updatedAt.prefix(10))
    }
    var replies: [BookStoryComment]?
    
    static func ==(lhs: BookStoryComment, rhs: BookStoryComment) -> Bool {
        return lhs.id == rhs.id
    }
}
