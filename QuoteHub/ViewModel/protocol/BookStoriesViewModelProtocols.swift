//
//  BookStoriesViewModelProtocols.swift
//  QuoteHub
//
//  Created by 이융의 on 6/21/25.
//

import SwiftUI

// MARK: - 기본 읽기 전용 프로토콜
protocol BookStoriesViewModelProtocol: LoadingViewModel {
    
    // MARK: - Published Properties
    var bookStories: [BookStory] { get }
    var isLastPage: Bool { get }
    var errorMessage: String? { get }
    
    // MARK: - Core Methods
    
    /// 북스토리 목록 로드 (첫 페이지)
    func loadBookStories() async
    
    /// 북스토리 목록 새로고침 (데이터 초기화 후 재로드)
    func refreshBookStories() async
    
    /// 무한 스크롤을 위한 추가 로드
    /// - Parameter currentItem: 현재 표시 중인 아이템
    func loadMoreIfNeeded(currentItem: BookStory?) async
    
    /// 특정 북스토리 상세 조회
    /// - Parameter storyId: 조회할 북스토리 ID
    /// - Returns: 조회된 북스토리 (실패시 nil)
    func fetchSpecificBookStory(storyId: String) async -> BookStory?
}

// MARK: - CRUD 확장 프로토콜 (My 뷰모델들만)
protocol EditableBookStoriesViewModelProtocol: BookStoriesViewModelProtocol {
    
    // MARK: - Create
    
    /// 새 북스토리 생성
    /// - Parameters:
    ///   - bookId: 책 ID
    ///   - quotes: 인용구 배열
    ///   - images: 첨부 이미지 배열
    ///   - content: 본문 내용
    ///   - isPublic: 공개 여부
    ///   - keywords: 키워드 배열
    ///   - themeIds: 테마 ID 배열
    /// - Returns: 생성된 북스토리 (실패시 nil)
    func createBookStory(
        bookId: String,
        quotes: [Quote],
        images: [UIImage]?,
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?
    ) async -> BookStory?
    
    // MARK: - Update
    
    /// 기존 북스토리 수정
    /// - Parameters:
    ///   - storyId: 수정할 북스토리 ID
    ///   - quotes: 수정된 인용구 배열
    ///   - images: 수정된 첨부 이미지 배열
    ///   - content: 수정된 본문 내용
    ///   - isPublic: 수정된 공개 여부
    ///   - keywords: 수정된 키워드 배열
    ///   - themeIds: 수정된 테마 ID 배열
    /// - Returns: 수정된 북스토리 (실패시 nil)
    func updateBookStory(
        storyId: String,
        quotes: [Quote],
        images: [UIImage]?,
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?
    ) async -> BookStory?
    
    // MARK: - Delete
    
    /// 북스토리 삭제
    /// - Parameter storyId: 삭제할 북스토리 ID
    /// - Returns: 삭제 성공 여부
    func deleteBookStory(storyId: String) async -> Bool
}

// MARK: - 프로토콜 기본 구현 (공통 로직)
extension BookStoriesViewModelProtocol {
    
    /// 페이지네이션 체크를 위한 헬퍼 메서드
    /// - Parameter item: 현재 아이템
    /// - Returns: 추가 로드가 필요한지 여부
    @MainActor
    func shouldLoadMore(for item: BookStory?) -> Bool {
        guard let item = item else { return false }
        guard !isLoading else { return false }
        guard !isLoading else { return false }
        
        // 현재 아이템이 마지막에서 3번째 이내면 추가 로드
        if let index = bookStories.firstIndex(where: { $0.id == item.id }) {
            return index >= bookStories.count - 3
        }
        
        return false
    }
    
    /// 에러 메시지 클리어
    func clearErrorMessage() {
        // 각 뷰모델에서 구현
    }
    
    /// 로딩 상태 초기화
    func resetLoadingState() {
        // 각 뷰모델에서 구현
    }
}

// MARK: - Typealias
typealias ReadOnlyBookStoriesViewModel = BookStoriesViewModelProtocol
typealias EditableBookStoriesViewModel = EditableBookStoriesViewModelProtocol
