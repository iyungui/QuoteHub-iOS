//
//  BookStoryCommentService.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import Foundation

protocol BookStoryCommentServiceProtocol {
    /// 댓글 추가
    func addComment(
        bookStoryId: String,
        content: String,
        parentCommentId: String?
    ) async throws -> APIResponse<BookStoryComment>
    
    /// 댓글 수정
    func updateComment(
        commentId: String,
        content: String
    ) async throws -> APIResponse<BookStoryComment>
    
    /// 댓글 삭제
    func deleteComment(
        commentId: String
    ) async throws -> APIResponse<EmptyData>
    
    /// 특정 북스토리의 댓글 조회
    func getCommentsForStory(
        bookStoryId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStoryComment>
    
    /// 특정 북스토리의 댓글 개수 조회
    func getCommentCountForStory(
        bookStoryId: String
    ) async throws -> APIResponse<Int>
}

final class BookStoryCommentService: BookStoryCommentServiceProtocol {
    
    // MARK: - Properties
    static let shared = BookStoryCommentService()
    
    private let apiClient: APIClient
    
    // MARK: - Initialization
    private init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    /// 댓글 추가
    func addComment(
        bookStoryId: String,
        content: String,
        parentCommentId: String? = nil
    ) async throws -> APIResponse<BookStoryComment> {
        
        // 입력 값 검증
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            throw NetworkError.serverError(400, "댓글 내용을 입력해주세요.")
        }
        
        // 요청 Body 구성
        var requestBody: [String: Any] = [
            "bookStoryId": bookStoryId,
            "content": trimmedContent
        ]
        
        if let parentCommentId = parentCommentId {
            requestBody["parentCommentId"] = parentCommentId
        }
        
        return try await apiClient.request(
            endpoint: BookStoryCommentEndpoints.addComment,
            body: .dictionary(requestBody),
            responseType: APIResponse<BookStoryComment>.self
        )
    }
    
    /// 댓글 수정
    func updateComment(
        commentId: String,
        content: String
    ) async throws -> APIResponse<BookStoryComment> {
        
        // 입력 값 검증
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            throw NetworkError.serverError(400, "댓글 내용을 입력해주세요.")
        }
        
        let requestBody = ["content": trimmedContent]
        
        return try await apiClient.request(
            endpoint: BookStoryCommentEndpoints.updateComment(commentId: commentId),
            body: .dictionary(requestBody),
            responseType: APIResponse<BookStoryComment>.self
        )
    }
    
    /// 댓글 삭제
    func deleteComment(
        commentId: String
    ) async throws -> APIResponse<EmptyData> {
        return try await apiClient.request(
            endpoint: BookStoryCommentEndpoints.deleteComment(commentId: commentId),
            body: .empty,
            responseType: APIResponse<EmptyData>.self
        )
    }
    
    /// 특정 북스토리의 댓글 조회
    func getCommentsForStory(
        bookStoryId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<BookStoryComment> {
        return try await apiClient.request(
            endpoint: BookStoryCommentEndpoints.getCommentsForStory(
                bookStoryId: bookStoryId,
                page: page,
                pageSize: pageSize
            ),
            body: .empty,
            responseType: PaginatedAPIResponse<BookStoryComment>.self
        )
    }
    
    /// 특정 북스토리의 댓글 개수 조회
    func getCommentCountForStory(
        bookStoryId: String
    ) async throws -> APIResponse<Int> {
        return try await apiClient.request(
            endpoint: BookStoryCommentEndpoints.getCommentCountForStory(bookStoryId: bookStoryId),
            body: .empty,
            responseType: APIResponse<Int>.self
        )
    }
}
