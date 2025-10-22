//
//  BookStoryService.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/01.
//

import SwiftUI

protocol BookStoryServiceProtocol {
    /// 북스토리 생성
    func createBookStory(
        images: [UIImage]?,
        bookId: String,
        quotes: [Quote],
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?
    ) async throws -> APIResponse<BookStory>
    
    /// 북스토리 수정
    func updateBookStory(
        storyId: String,
        quotes: [Quote],
        images: [UIImage]?,
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?
    ) async throws -> APIResponse<BookStory>
    
    /// 북스토리 삭제
    func deleteBookStory(
        storyId: String
    ) async throws -> APIResponse<EmptyData>
    
    /// 특정 북스토리 하나 조회
    func fetchSpecificBookStory(
        storyId: String
    ) async throws -> APIResponse<BookStory>
    
    /// 북스토리 조회 (public)
    func fetchPublicBookStories(
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory>
    
    /// 북스토리 조회 (friend)
    func fetchFriendBookStories(
        friendId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory>
    
    /// 북스토리 조회 (my)
    func fetchMyBookStories(
        page: Int, pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory>
    
    /// 키워드별 북스토리 조회(public)
    func fetchPublicBookStoriesByKeyword(
        keyword: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory>
    
    /// 키워드별 북스토리 조회(friend)
    func fetchFriendBookStoriesByKeyword(
        friendId: String,
        keyword: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory>

    /// 키워드별 북스토리 조회(my)
    func fetchMyBookStoriesByKeyword(
        keyword: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory>

    /// 테마별 북스토리 조회(public)
    func fetchPublicBookStoriesByTheme(
        themeId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory>
    
    /// 테마별 북스토리 조회(friend)
    func fetchFriendBookStoriesByTheme(
        themeId: String,
        friendId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory>
    
    /// 테마별 북스토리 조회(my)
    func fetchMyBookStoriesByTheme(
        themeId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory>
}

final class BookStoryService: BookStoryServiceProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    /// 북스토리 생성
    func createBookStory(
        images: [UIImage]? = nil,
        bookId: String,
        quotes: [Quote],
        content: String? = nil,
        isPublic: Bool = false,
        keywords: [String]? = nil,
        themeIds: [String]? = nil
    ) async throws -> APIResponse<BookStory> {
        
        // quotes 필수 검증
        guard !quotes.isEmpty else {
            throw NetworkError.serverError(400, "최소 하나의 문장이 필요합니다.")
        }
        
        // 각 quote의 유효성 검증
        for quote in quotes {
            guard !quote.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw NetworkError.serverError(400, "문장 내용은 비어있을 수 없습니다.")
            }
        }
        
        // 공통 필드 구성
        var fields: [String: Any] = [
            "bookId": bookId,
            "quotes": quotes,
            "isPublic": isPublic
        ]
        
        if let content = content, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fields["content"] = content
        }
        
        if let keywords = keywords, !keywords.isEmpty {
            fields["keywords"] = keywords
        }
        
        if let themeIds = themeIds, !themeIds.isEmpty {
            fields["folderIds"] = themeIds
        }
        
        // 요청 Body 타입 결정
        let requestBody: RequestBody
        
        // 이미지가 있는 경우: Multipart 요청
        if let images = images, !images.isEmpty {
            requestBody = .multipart(
                textFields: fields,
                imageArrays: ["storyImage": images] // storyImage 필드로 images 이미지를 업로드하겠다는 뜻
            )
        } else {
            // 이미지가 없는 경우: JSON 요청
            requestBody = .dictionary(fields)
        }
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.createBookStory,
            body: requestBody,
            responseType: APIResponse<BookStory>.self
        )
    }
    
    /// 북스토리 수정
    func updateBookStory(
        storyId: String,
        quotes: [Quote],
        images: [UIImage]? = nil,
        content: String? = nil,
        isPublic: Bool,
        keywords: [String]? = nil,
        themeIds: [String]? = nil
    ) async throws -> APIResponse<BookStory> {
        
        // quotes 필수 검증
        guard !quotes.isEmpty else {
            throw NetworkError.serverError(400, "최소 하나의 문장이 필요합니다.")
        }
        
        // 각 quote의 유효성 검증
        for quote in quotes {
            guard !quote.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw NetworkError.serverError(400, "문장 내용은 비어있을 수 없습니다.")
            }
        }
        
        // 공통 필드 구성
        var fields: [String: Any] = [
            "quotes": quotes,
            "isPublic": isPublic
        ]
        
        if let content = content {
            fields["content"] = content
        }
        
        if let keywords = keywords {
            fields["keywords"] = keywords
        }
        
        if let themeIds = themeIds {
            fields["folderIds"] = themeIds
        }
        
        // 요청 Body 타입 결정
        let requestBody: RequestBody
        
        if let images = images, !images.isEmpty {
            // 이미지가 있는 경우: Multipart 요청
            requestBody = .multipart(
                textFields: fields,
                imageArrays: ["storyImage": images]
            )
        } else {
            // 이미지가 없는 경우: JSON 요청
            requestBody = .dictionary(fields)
        }
        
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.updateBookStory(storyId: storyId),
            body: requestBody,
            responseType: APIResponse<BookStory>.self
        )
    }

    /// 내 북스토리 삭제
    func deleteBookStory(
        storyId: String
    ) async throws -> APIResponse<EmptyData> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.deleteBookStory(storyId: storyId),
            body: .empty,
            responseType: APIResponse<EmptyData>.self
        )
    }
    
    /// 특정 북스토리 하나 조회
    func fetchSpecificBookStory(
        storyId: String
    ) async throws -> APIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchSpecificBookStory(storyId: storyId),
            body: .empty,
            responseType: APIResponse<BookStory>.self
        )
    }
    
    /// 모든 사용자의 공개된 북스토리 조회
    func fetchPublicBookStories(
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchPublicBookStories(page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
    
    /// 특정 사용자의 공개된 북스토리 조회
    func fetchFriendBookStories(
        friendId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchFriendBookStories(friendId: friendId, page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
    
    /// 내 서재 북스토리 조회
    func fetchMyBookStories(
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchMyBookStories(page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
    
    func fetchPublicBookStoriesByKeyword(
        keyword: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchPublicBookStoriesByKeyword(keyword: keyword, page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
    
    func fetchFriendBookStoriesByKeyword(
        friendId: String,
        keyword: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchFriendBookStoriesByKeyword(friendId: friendId, keyword: keyword, page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
    
    func fetchMyBookStoriesByKeyword(
        keyword: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchMyBookStoriesByKeyword(keyword: keyword, page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
    
    func fetchPublicBookStoriesByTheme(
        themeId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchPublicBookStoriesByTheme(themeId: themeId, page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
    
    func fetchFriendBookStoriesByTheme(
        themeId: String,
        friendId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchFriendBookStoriesByTheme(themeId: themeId, friendId: friendId, page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
    
    func fetchMyBookStoriesByTheme(
        themeId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchMyBookStoriesByTheme(themeId: themeId, page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
}
