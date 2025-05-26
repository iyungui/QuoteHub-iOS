//
//  APIResponse.swift
//  QuoteHub
//
//  Created by 이융의 on 10/15/23.
//

import Foundation


struct BackendErrorResponse: Codable {
    let error: String
}

struct DeleteResponse: Codable {
    let success: Bool
    let message: String
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


struct RandomBooksResponse: Codable {
    let success: Bool
    let data: [Book]
}

struct BooksResponse: Codable {
    let documents: [Book]
    let meta: Meta
}


struct FolderResponse: Codable {
    var success: Bool
    var data: Folder
    var message: String?
}


struct FolderListResponse: Codable {
    var success: Bool
    var data: [Folder]
    var currentPage: Int
    var totalPages: Int
    var pageSize: Int
    var totalItems: Int
    let message: String?
}


struct BookStoriesResponse: Codable {
    var success: Bool
    var data: [BookStory]
    var currentPage: Int
    var totalPages: Int
    var pageSize: Int
    var totalItems: Int
    let message: String?
}

struct BookStoryResponse: Codable {
    let success: Bool
    let data: BookStory
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case message
    }
}

struct UserResponse: Codable {
    let success: Bool
    let data: User
    let error: String?
}
