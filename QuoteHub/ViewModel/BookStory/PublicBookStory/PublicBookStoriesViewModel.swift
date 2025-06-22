//
//  PublicBookStoriesViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/21/25.
//

import SwiftUI

@MainActor
@Observable
final class PublicBookStoriesViewModel: BookStoriesViewModelProtocol {
    
    // MARK: - LoadingViewModel Protocol
    var isLoading = false
    var loadingMessage: String?
    
    // MARK: - BookStoriesViewModelProtocol
    var bookStories: [BookStory] = []
    var isLastPage = false
    var errorMessage: String?
    
    // MARK: - Private Properties
    private var currentPage = 1
    private let pageSize = 10
    private let service: BookStoryServiceProtocol
    
    // MARK: - Task Management
    private var loadingTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(service: BookStoryServiceProtocol = BookStoryService()) {
        self.service = service
    }
    
//    deinit {
//        cancelAllTasks()
//    }
}

// MARK: - Core Reading Methods
extension PublicBookStoriesViewModel {
    
    func loadBookStories() async {
        // 이미 로딩 중이거나 마지막 페이지면 중단
        guard loadingTask == nil else { return }
        guard !isLastPage else { return }
        
        loadingTask = Task { @MainActor in
            await performLoadBookStories()
        }
    }
    
    func refreshBookStories() async {
        // 기존 로딩 취소
        cancelLoadingTask()
        
        // 상태 초기화
        currentPage = 1
        isLastPage = false
        bookStories = []
        
        // 새로 로드
        await loadBookStories()
    }
    
    func loadMoreIfNeeded(currentItem: BookStory?) async {
        guard shouldLoadMore(for: currentItem) else { return }
        await loadBookStories()
    }
    
    func fetchSpecificBookStory(storyId: String) async -> BookStory? {
        isLoading = true
        loadingMessage = "북스토리를 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.fetchSpecificBookStory(storyId: storyId)
            
            if response.success {
                return response.data
            } else {
                errorMessage = response.message
                return nil
            }
        } catch {
            handleError(error)
            return nil
        }
    }
    
    private func performLoadBookStories() async {
        isLoading = true
        loadingMessage = "공개 북스토리를 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
            loadingTask = nil
        }
        
        do {
            let response = try await service.fetchPublicBookStories(
                page: currentPage,
                pageSize: pageSize
            )
            
            // Task 취소 확인
            try Task.checkCancellation()
            
            // 기존 데이터에 추가
            bookStories.append(contentsOf: response.data)
            
            // 페이지네이션 상태 업데이트
            isLastPage = response.pagination.currentPage >= response.pagination.totalPages
            if !isLastPage {
                currentPage += 1
            }
            
            print("✅ PublicBookStoriesViewModel: \(response.data.count)개 북스토리 로드 완료")
            
        } catch is CancellationError {
            return
        } catch {
            handleError(error)
        }
    }
}

// MARK: - Helper Methods
extension PublicBookStoriesViewModel {
    
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    private func cancelLoadingTask() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    private func cancelAllTasks() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다.: \(error.localizedDescription)"
        }
        print("❌ PublicBookStoriesViewModel 에러: \(error)")
    }
}
