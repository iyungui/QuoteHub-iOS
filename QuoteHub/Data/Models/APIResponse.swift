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

typealias BookStoryCommentsResponse = PaginatedAPIResponse<BookStoryComment>    // 댓글 조회
typealias BookStoryCommentResponse = APIResponse<BookStoryComment>  // 댓글 올리기

typealias CommentCountResponse = APIResponse<Int>

typealias FolderResponse = APIResponse<Theme>
typealias FolderListResponse = PaginatedAPIResponse<Theme>

typealias RandomBooksResponse = APIResponse<[Book]>

typealias BookStoryResponse = APIResponse<BookStory>
typealias BookStoriesResponse = PaginatedAPIResponse<BookStory>


typealias SearchUserResponse = APIResponse<[User]>

typealias FollowListResponse = PaginatedAPIResponse<User>
typealias FollowCountResponse = APIResponse<FollowCount>
typealias FollowResponse = APIResponse<User>
typealias FollowStatusResponse = APIResponse<Follow> // 팔로우 차단 및 차단 해제
typealias CheckFollowStatusResponse = APIResponse<CheckFollowStatus>    // 차단상태 확인

//// 팔로워, 팔로잉 목록 조회
//struct FollowListResponse: Codable {
//    var success: Bool
//    var data: [User]
//    var currentPage: Int
//    var totalPages: Int
//    var pageSize: Int
//    var totalItems: Int
//    let error: String?
//}
//// 팔로우, 팔로우 해제
//struct FollowResponse: Codable {
//    var success: Bool
//    var data: User
//    let error: String?
//}

//// 팔로우 차단 및 차단 해제
//struct FollowStatusResponse: Codable {
//    var success: Bool?
//    var data: Follow?
//    var message: String?
//    var error: String?
//}
