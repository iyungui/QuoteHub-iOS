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
    private let apiClient: APIClient
    
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
        
        // 텍스트 필드 설정
        var textFields: [String: Any] = [
            "bookId": bookId,
            "quotes": quotes,  // APIClient에서 JSON으로 변환
            "isPublic": isPublic
        ]
        
        // 옵셔널 필드들 추가
        if let content = content, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textFields["content"] = content
        }
        
        if let keywords = keywords, !keywords.isEmpty {
            textFields["keywords"] = keywords
        }
        
        if let themeIds = themeIds, !themeIds.isEmpty {
            textFields["folderIds"] = themeIds
        }
        
        // 이미지 필드 설정 (리사이즈는 APIClient에서 처리)
        var imageFields: [String: UIImage] = [:]
        if let images = images, !images.isEmpty {
            for (index, image) in images.enumerated() {
                imageFields["storyImage\(index)"] = image
            }
        }
        
        return try await apiClient.requestWithMultipart(
            endpoint: BookStoryEndpoints.createBookStory,
            textFields: textFields,
            imageFields: imageFields,
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
        
        // 텍스트 필드 설정 (업데이트할 필드만 포함)
        var textFields: [String: Any] = [
            "quotes": quotes,  // APIClient에서 JSON으로 변환
            "isPublic": isPublic
        ]
        
        // 선택적 필드들 추가
        if let content = content {
            textFields["content"] = content
        }
        
        if let keywords = keywords {
            textFields["keywords"] = keywords
        }
        
        if let themeIds = themeIds {
            textFields["folderIds"] = themeIds
        }
        
        // 이미지 필드 설정 (리사이즈는 APIClient에서 처리)
        var imageFields: [String: UIImage] = [:]
        if let images = images, !images.isEmpty {
            for (index, image) in images.enumerated() {
                imageFields["storyImage\(index)"] = image
            }
        }
        
        return try await apiClient.requestWithMultipart(
            endpoint: BookStoryEndpoints.updateBookStory(storyId: storyId),
            textFields: textFields,
            imageFields: imageFields,
            responseType: APIResponse<BookStory>.self
        )
    }
    
    /// 내 북스토리 삭제
    func deleteBookStory(
        storyId: String
    ) async throws -> APIResponse<EmptyData> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.deleteBookStory(storyId: storyId),
            body: EmptyData(),
            responseType: APIResponse<EmptyData>.self
        )
    }
    
    /// 특정 북스토리 하나 조회
    func fetchSpecificBookStory(
        storyId: String
    ) async throws -> APIResponse<BookStory> {
        return try await apiClient.request(
            endpoint: BookStoryEndpoints.fetchSpecificBookStory(storyId: storyId),
            body: EmptyData(),
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
            body: EmptyData(),
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
            body: EmptyData(),
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
            body: EmptyData(),
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
            body: EmptyData(),
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
            body: EmptyData(),
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
            body: EmptyData(),
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
            body: EmptyData(),
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
            body: EmptyData(),
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
            body: EmptyData(),
            responseType: PaginatedAPIResponse<BookStory>.self
        )
    }
}
