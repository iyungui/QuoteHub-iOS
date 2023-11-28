//
//  BookStoryCommentDataModel.swift
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
//    struct User: Codable {
//        var _id: String
//        var nickname: String
//        var profileImage: String
//    }
    var replies: [BookStoryComment]?
    
    static func ==(lhs: BookStoryComment, rhs: BookStoryComment) -> Bool {
        return lhs.id == rhs.id
    }
}

struct BookStoryCommentResponse: Codable {
    var success: Bool
    var data: [BookStoryComment]
    var page: Int
    var pageSize: Int
    var totalRootComments: Int
    var totalPages: Int
    var message: String?
}

struct postCommentResponse: Codable {
    var success: Bool
    var data: BookStoryComment
    var message: String?
}

struct CommentCountResponse: Codable {
    var commentCount: Int
    var message: String?
}
