//
//  FriendLibraryKeywordsViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/28/25.
//

import SwiftUI

@MainActor
@Observable
final class FriendLibraryKeywordsViewModel: LoadingViewModelProtocol {
    
    // MARK: - LoadingViewModel Protocol
    var isLoading = false
    var loadingMessage: String?
    
    // MARK: - Published Properties
    var keywords: [KeywordInfo] = []
    var sortOption: KeywordSortOption = .frequency
    var errorMessage: String?
    
    // MARK: - Private Properties
    private let friendBookStoriesViewModel: FriendBookStoriesViewModel
    
    // MARK: - Task Management
    private var processingTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(friendBookStoriesViewModel: FriendBookStoriesViewModel) {
        self.friendBookStoriesViewModel = friendBookStoriesViewModel
        setupNotificationObservers()
        processKeywords()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
//        cancelAllTasks()
    }
}

// MARK: - Notification Observer Setup
extension FriendLibraryKeywordsViewModel {
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookStoryChanged),
            name: .bookStoryCreated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookStoryChanged),
            name: .bookStoryUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookStoryChanged),
            name: .bookStoryDeleted,
            object: nil
        )
    }
    
    @objc private func handleBookStoryChanged() {
        // 북스토리가 변경되면 키워드 재처리
        processKeywords()
    }
}

// MARK: - Public Methods
extension FriendLibraryKeywordsViewModel {
    
    func refreshKeywords() {
        processKeywords()
    }
    
    func changeSortOption(_ option: KeywordSortOption) {
        sortOption = option
        sortKeywords()
    }
    
    func toggleSortOption() {
        let newOption: KeywordSortOption = sortOption == .frequency ? .alphabetical : .frequency
        changeSortOption(newOption)
    }
}

// MARK: - Private Methods
extension FriendLibraryKeywordsViewModel {
    
    private func processKeywords() {
        // 기존 작업 취소
        processingTask?.cancel()
        
        processingTask = Task { @MainActor in
            await performProcessKeywords()
        }
    }
    
    private func performProcessKeywords() async {
        isLoading = true
        loadingMessage = "키워드를 분석하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            try Task.checkCancellation()
            
            // 모든 친구 북스토리에서 키워드 추출
            let keywordCounts = extractKeywordCounts(from: friendBookStoriesViewModel.bookStories)
            
            try Task.checkCancellation()
            
            // KeywordInfo 배열 생성
            let keywordInfos = keywordCounts.map { keyword, count in
                KeywordInfo(keyword: keyword, count: count)
            }
            
            keywords = keywordInfos
            sortKeywords()
            
        } catch is CancellationError {
            return
        } catch {
            handleError(error)
        }
    }
    
    private func extractKeywordCounts(from stories: [BookStory]) -> [String: Int] {
        var keywordCounts: [String: Int] = [:]
        
        for story in stories {
            guard let storyKeywords = story.keywords else { continue }
            
            for keyword in storyKeywords {
                let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmedKeyword.isEmpty else { continue }
                
                keywordCounts[trimmedKeyword, default: 0] += 1
            }
        }
        
        return keywordCounts
    }
    
    private func sortKeywords() {
        switch sortOption {
        case .frequency:
            keywords.sort { $0.count > $1.count || ($0.count == $1.count && $0.keyword < $1.keyword) }
        case .alphabetical:
            keywords.sort { $0.keyword < $1.keyword }
        }
    }
    
    private func clearErrorMessage() {
        errorMessage = nil
    }
    
    private func cancelAllTasks() {
        processingTask?.cancel()
        processingTask = nil
    }
    
    private func handleError(_ error: Error) {
        errorMessage = "키워드 분석 중 오류가 발생했습니다: \(error.localizedDescription)"
        print("❌ FriendLibraryKeywordsViewModel 에러: \(error)")
    }
}
