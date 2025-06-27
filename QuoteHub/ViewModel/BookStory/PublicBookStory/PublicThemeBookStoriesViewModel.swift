//
//  PublicThemeBookStoriesViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/28/25.
//

import Foundation

// MARK: - PublicThemeBookStoriesViewModel

@MainActor
@Observable
final class PublicThemeBookStoriesViewModel: BookStoriesViewModelProtocol {
    
    // MARK: - LoadingViewModel Protocol
    var isLoading = false
    var loadingMessage: String?
    
    // MARK: - BookStoriesViewModelProtocol
    var bookStories: [BookStory] = []
    var isLastPage = false
    var errorMessage: String?
    
    // MARK: - Unique Properties
    let themeId: String
    
    // MARK: - Private Properties
    private var currentPage = 1
    private let pageSize = 10
    private let service: BookStoryServiceProtocol
    private var loadingTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(themeId: String, service: BookStoryServiceProtocol = BookStoryService()) {
        self.themeId = themeId
        self.service = service
    }
    
//    deinit {
//        cancelAllTasks()
//    }
    
    // MARK: - Core Methods
    func loadBookStories() async {
        guard loadingTask == nil else { return }
        guard !isLastPage else { return }
        
        loadingTask = Task { @MainActor in
            await performLoadBookStories()
        }
    }
    
    func refreshBookStories() async {
        cancelLoadingTask()
        currentPage = 1
        isLastPage = false
        bookStories = []
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
            return response.success ? response.data : nil
        } catch {
            handleError(error)
            return nil
        }
    }
    
    private func performLoadBookStories() async {
        isLoading = true
        loadingMessage = "테마 북스토리를 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
            loadingTask = nil
        }
        
        do {
            let response = try await service.fetchPublicBookStoriesByTheme(
                themeId: themeId,
                page: currentPage,
                pageSize: pageSize
            )
            
            try Task.checkCancellation()
            
            bookStories.append(contentsOf: response.data)
            isLastPage = response.pagination.currentPage >= response.pagination.totalPages
            if !isLastPage {
                currentPage += 1
            }
            
        } catch is CancellationError {
            return
        } catch {
            handleError(error)
        }
    }
    
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    private func cancelLoadingTask() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    private func cancelAllTasks() {
        cancelLoadingTask()
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다.: \(error.localizedDescription)"
        }
    }
}
