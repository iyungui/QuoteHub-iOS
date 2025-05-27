//
//  APIResponse.swift
//  QuoteHub
//
//  Created by 이융의 on 10/15/23.
//

import Foundation

// MARK: - Base Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: T?
}

struct Pagination: Codable {
    let currentPage: Int
    let totalPages: Int
    let pageSize: Int
    let totalItems: Int
}

struct PaginatedAPIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String
    let data: [T]
    let pagination: Pagination
}

struct ErrorResponse: Codable {
    let success: Bool
    let message: String
    let errors: [String: String]?
}

struct CountResponse: Codable {
    let success: Bool
    let message: String
    let count: Int
}

// Kakao API Response
struct BooksResponse: Codable {
    let documents: [Book]
    let meta: Meta
}
struct Meta: Codable {
    let is_end: Bool
    let pageable_count: Int
    let total_count: Int
}

// data를 전달하지 않는 api 위한 모델
struct EmptyData: Codable {}

// MARK: - Specific Response Type Aliases

typealias UserResponse = APIResponse<User>
typealias SearchUserResponse = APIResponse<[User]>

typealias BookStoryCommentsResponse = PaginatedAPIResponse<BookStoryComment>
typealias BookStoryCommentResponse = APIResponse<BookStoryComment>

typealias CommentCountResponse = APIResponse<Int>

typealias FolderResponse = APIResponse<Folder>
typealias FolderListResponse = PaginatedAPIResponse<Folder>

typealias RandomBooksResponse = APIResponse<[Book]>

typealias BookStoryResponse = APIResponse<BookStory>
typealias BookStoriesResponse = PaginatedAPIResponse<BookStory>
