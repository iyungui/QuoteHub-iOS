//
//  APIResponse.swift
//  QuoteHub
//
//  Created by 이융의 on 10/15/23.
//

import Foundation

// MARK: - Base Response Models

protocol APIResponseProtocol {
    var success: Bool { get }
    var message: String { get }
}

struct APIResponse<T: Codable>: Codable, APIResponseProtocol {
    let success: Bool
    let message: String
    let data: T?
    let errors: [String: String]?
}

struct Pagination: Codable {
    let currentPage: Int
    let totalPages: Int
    let pageSize: Int
    let totalItems: Int
}

// 만약 에러 시 APIResponse 로...
struct PaginatedAPIResponse<T: Codable>: Codable, APIResponseProtocol {
    let success: Bool
    let message: String
    let data: [T]
    let pagination: Pagination
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

typealias ThemeResponse = APIResponse<Theme>
typealias ThemesListResponse = PaginatedAPIResponse<Theme>

typealias RandomBooksResponse = APIResponse<[Book]>

typealias BookStoryResponse = APIResponse<BookStory>
typealias BookStoriesResponse = PaginatedAPIResponse<BookStory>


typealias SearchUserResponse = APIResponse<[User]>

typealias FollowListResponse = PaginatedAPIResponse<User>
typealias FollowCountResponse = APIResponse<FollowCount>
typealias FollowResponse = APIResponse<User>
typealias FollowStatusResponse = APIResponse<Follow> // 팔로우 차단 및 차단 해제
typealias CheckFollowStatusResponse = APIResponse<CheckFollowStatus>    // 차단상태 확인


