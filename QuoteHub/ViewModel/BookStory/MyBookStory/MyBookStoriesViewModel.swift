//
//  MyBookStoriesViewModel.swift
//  QuoteHub
//
//  Created by BookStoriesViewModel Architecture
//

import SwiftUI

@MainActor
@Observable
final class MyBookStoriesViewModel: EditableBookStoriesViewModelProtocol {
    
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
    private var operationTasks: Set<Task<BookStory?, Never>> = []
    private var deletionTask: Task<Bool, Never>?
    
    // MARK: - Initialization
    init(service: BookStoryServiceProtocol = BookStoryService()) {
        self.service = service
    }
}

// MARK: - Core Reading Methods
extension MyBookStoriesViewModel {
    
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
        loadingMessage = "내 북스토리를 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
            loadingTask = nil
        }
        
        do {
            let response = try await service.fetchMyBookStories(
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
            
        } catch is CancellationError {
            return
        } catch {
            handleError(error)
        }
    }
}

// MARK: - CRUD Methods (핵심 기능)
extension MyBookStoriesViewModel {
    
    func createBookStory(
        bookId: String,
        quotes: [Quote],
        images: [UIImage]? = nil,
        content: String? = nil,
        isPublic: Bool,
        keywords: [String]? = nil,
        themeIds: [String]? = nil
    ) async -> BookStory? {
        let task = Task { @MainActor in
            await performCreateBookStory(
                bookId: bookId,
                quotes: quotes,
                images: images,
                content: content,
                isPublic: isPublic,
                keywords: keywords,
                themeIds: themeIds
            )
        }
        
        operationTasks.insert(task)
        let result = await task.value
        operationTasks.remove(task)
        
        return result
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
        let task = Task { @MainActor in
            await performUpdateBookStory(
                storyId: storyId,
                quotes: quotes,
                images: images,
                content: content,
                isPublic: isPublic,
                keywords: keywords,
                themeIds: themeIds
            )
        }
        
        operationTasks.insert(task)
        let result = await task.value
        operationTasks.remove(task)
        
        return result
    }
    
    func deleteBookStory(storyId: String) async -> Bool {
        deletionTask = Task { @MainActor in
            await performDeleteBookStory(storyId: storyId)
        }
        
        let result = await (deletionTask?.value ?? false)
        return result
    }
    
    // MARK: - Private CRUD Implementation
    
    private func performCreateBookStory(
        bookId: String,
        quotes: [Quote],
        images: [UIImage]?,
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?
    ) async -> BookStory? {
        isLoading = true
        loadingMessage = "북스토리를 등록하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.createBookStory(
                images: images,
                bookId: bookId,
                quotes: quotes,
                content: content,
                isPublic: isPublic,
                keywords: keywords,
                themeIds: themeIds
            )
            
            try Task.checkCancellation()
            
            guard response.success, let newStory = response.data else {
                errorMessage = response.message
                return nil
            }
            
            // 1. 자신의 로컬 데이터 즉시 업데이트
            bookStories.insert(newStory, at: 0)
            
            // 2. 다른 뷰모델들에게 이벤트 발송
            NotificationCenter.default.post(
                name: .bookStoryCreated,
                object: nil,
                userInfo: [Notification.BookStoryKeys.story: newStory]
            )
            
            print("✅ 북스토리 생성 완료 - ID: \(newStory.id)")
            return newStory
            
        } catch is CancellationError {
            return nil
        } catch {
            handleError(error)
            return nil
        }
    }
    
    private func performUpdateBookStory(
        storyId: String,
        quotes: [Quote],
        images: [UIImage]?,
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?
    ) async -> BookStory? {
        isLoading = true
        loadingMessage = "북스토리를 수정하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        // 수정 전 상태 저장 (이벤트용)
        let previousStory = bookStories.first(where: { $0.id == storyId })
        
        do {
            let response = try await service.updateBookStory(
                storyId: storyId,
                quotes: quotes,
                images: images,
                content: content,
                isPublic: isPublic,
                keywords: keywords,
                themeIds: themeIds
            )
            
            try Task.checkCancellation()
            
            guard let updatedStory = response.data else {
                errorMessage = "북스토리 수정에 실패했습니다."
                return nil
            }
            
            // 1. 자신의 로컬 데이터 업데이트
            updateStoryInLocal(updatedStory)
            
            // 2. 다른 뷰모델들에게 이벤트 발송
            var userInfo: [String: Any] = [Notification.BookStoryKeys.story: updatedStory]
            if let previousStory = previousStory {
                userInfo[Notification.BookStoryKeys.previousStory] = previousStory
            }
            NotificationCenter.default.post(
                name: .bookStoryUpdated,
                object: nil,
                userInfo: userInfo
            )
            
            print("✅ 북스토리 수정 완료 - ID: \(updatedStory.id)")
            return updatedStory
            
        } catch is CancellationError {
            return nil
        } catch {
            handleError(error)
            return nil
        }
    }
    
    private func performDeleteBookStory(storyId: String) async -> Bool {
        isLoading = true
        loadingMessage = "북스토리를 삭제하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            _ = try await service.deleteBookStory(storyId: storyId)
            
            try Task.checkCancellation()
            
            // 1. 자신의 로컬 데이터에서 삭제
            removeStoryFromLocal(storyId: storyId)
            
            // 2. 다른 뷰모델들에게 이벤트 발송
            NotificationCenter.default.post(
                name: .bookStoryDeleted,
                object: nil,
                userInfo: [Notification.BookStoryKeys.deletedStoryId: storyId]
            )
            
            print("✅ 북스토리 삭제 완료 - ID: \(storyId)")
            return true
            
        } catch is CancellationError {
            return false
        } catch {
            handleError(error)
            return false
        }
    }
}

// MARK: - Helper Methods
extension MyBookStoriesViewModel {
    
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
        print("❌ MyBookStoriesViewModel 에러: \(error)")
    }
}
