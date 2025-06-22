//
//  MySearchBookStoriesViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

@MainActor
@Observable
final class MySearchBookStoriesViewModel: EditableBookStoriesViewModelProtocol {
    
    // MARK: - LoadingViewModel Protocol
    var isLoading = false
    var loadingMessage: String?
    
    // MARK: - BookStoriesViewModelProtocol
    var bookStories: [BookStory] = []
    var isLastPage = false
    var errorMessage: String?
    
    // MARK: - Unique Properties
    let keyword: String
    
    // MARK: - Private Properties
    private var currentPage = 1
    private let pageSize = 10
    private let service: BookStoryServiceProtocol
    
    // MARK: - Task Management
    private var loadingTask: Task<Void, Never>?
    private var operationTasks: Set<Task<BookStory?, Never>> = []
    private var deletionTask: Task<Bool, Never>?
    
    // MARK: - Initialization
    init(keyword: String, service: BookStoryServiceProtocol = BookStoryService()) {
        self.keyword = keyword
        self.service = service
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Notification Observer Setup
extension MySearchBookStoriesViewModel {
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookStoryCreated(_:)),
            name: .bookStoryCreated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookStoryUpdated(_:)),
            name: .bookStoryUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookStoryDeleted(_:)),
            name: .bookStoryDeleted,
            object: nil
        )
    }
    
    @objc private func handleBookStoryCreated(_ notification: Notification) {
        guard let story = notification.userInfo?[Notification.BookStoryKeys.story] as? BookStory else { return }
        
        // 키워드 매치 확인
        if isStoryMatchingKeyword(story) {
            bookStories.insert(story, at: 0)
            print("✅ MySearchBookStoriesViewModel: 새 북스토리 추가 - \(story.id)")
        }
    }
    
    @objc private func handleBookStoryUpdated(_ notification: Notification) {
        guard let updatedStory = notification.userInfo?[Notification.BookStoryKeys.story] as? BookStory else { return }
        let previousStory = notification.userInfo?[Notification.BookStoryKeys.previousStory] as? BookStory
        
        // 기존 스토리가 목록에 있었는지 확인
        let wasInList = bookStories.contains { $0.id == updatedStory.id }
        let shouldBeInList = isStoryMatchingKeyword(updatedStory)
        
        if wasInList && shouldBeInList {
            // 키워드 매치하고 이미 목록에 있음 → 업데이트
            updateStoryInLocal(updatedStory)
            print("✅ MySearchBookStoriesViewModel: 북스토리 업데이트 - \(updatedStory.id)")
        } else if !wasInList && shouldBeInList {
            // 키워드 매치하지만 목록에 없음 → 추가
            bookStories.insert(updatedStory, at: 0)
            print("✅ MySearchBookStoriesViewModel: 수정된 북스토리 추가 - \(updatedStory.id)")
        } else if wasInList && !shouldBeInList {
            // 목록에 있지만 더이상 키워드 매치 안함 → 제거
            removeStoryFromLocal(storyId: updatedStory.id)
            print("✅ MySearchBookStoriesViewModel: 키워드 불일치로 북스토리 제거 - \(updatedStory.id)")
        }
    }
    
    @objc private func handleBookStoryDeleted(_ notification: Notification) {
        guard let deletedStoryId = notification.userInfo?[Notification.BookStoryKeys.deletedStoryId] as? String else { return }
        
        // 목록에서 제거
        removeStoryFromLocal(storyId: deletedStoryId)
        print("✅ MySearchBookStoriesViewModel: 북스토리 삭제 - \(deletedStoryId)")
    }
    
    private func isStoryMatchingKeyword(_ story: BookStory) -> Bool {
        // 키워드 배열에서 검색어가 포함된 키워드가 있는지 확인
        return story.keywords?.contains { storyKeyword in
            storyKeyword.localizedCaseInsensitiveContains(keyword)
        } ?? false
    }
}

// MARK: - Core Reading Methods
extension MySearchBookStoriesViewModel {
    
    func loadBookStories() async {
        guard loadingTask == nil else { return }
        guard !isLastPage else { return }
        
        // 키워드가 비어있으면 로드하지 않음
        guard !keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
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
        loadingMessage = "키워드 검색 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
            loadingTask = nil
        }
        
        do {
            let response = try await service.fetchMyBookStoriesByKeyword(
                keyword: keyword,
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
}

// MARK: - CRUD Methods (위임 방식)
extension MySearchBookStoriesViewModel {
    
    func createBookStory(
        bookId: String,
        quotes: [Quote],
        images: [UIImage]? = nil,
        content: String? = nil,
        isPublic: Bool,
        keywords: [String]? = nil,
        themeIds: [String]? = nil
    ) async -> BookStory? {
        // MyBookStoriesViewModel에 위임
        let mainViewModel = MyBookStoriesViewModel(service: service)
        return await mainViewModel.createBookStory(
            bookId: bookId,
            quotes: quotes,
            images: images,
            content: content,
            isPublic: isPublic,
            keywords: keywords,
            themeIds: themeIds
        )
    }
    
    func updateBookStory(
        storyId: String,
        quotes: [Quote],
        images: [UIImage]? = nil,
        content: String? = nil,
        isPublic: Bool,
        keywords: [String]? = nil,
        themeIds: [String]? = nil
    ) async -> BookStory? {
        // MyBookStoriesViewModel에 위임
        let mainViewModel = MyBookStoriesViewModel(service: service)
        return await mainViewModel.updateBookStory(
            storyId: storyId,
            quotes: quotes,
            images: images,
            content: content,
            isPublic: isPublic,
            keywords: keywords,
            themeIds: themeIds
        )
    }
    
    func deleteBookStory(storyId: String) async -> Bool {
        // MyBookStoriesViewModel에 위임
        let mainViewModel = MyBookStoriesViewModel(service: service)
        return await mainViewModel.deleteBookStory(storyId: storyId)
    }
}

// MARK: - Helper Methods
extension MySearchBookStoriesViewModel {
    
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    private func updateStoryInLocal(_ story: BookStory) {
        if let index = bookStories.firstIndex(where: { $0.id == story.id }) {
            bookStories[index] = story
        }
    }
    
    private func removeStoryFromLocal(storyId: String) {
        bookStories.removeAll { $0.id == storyId }
    }
    
    private func cancelLoadingTask() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    private func cancelAllTasks() {
        loadingTask?.cancel()
        loadingTask = nil
        
        for task in operationTasks {
            task.cancel()
        }
        operationTasks.removeAll()
        
        deletionTask?.cancel()
        deletionTask = nil
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다.: \(error.localizedDescription)"
        }
        print("❌ MySearchBookStoriesViewModel 에러: \(error)")
    }
}
