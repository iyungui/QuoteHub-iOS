//
//  PublicThemesViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

@MainActor
@Observable
final class PublicThemesViewModel: ThemesViewModelProtocol {
    
    // MARK: - LoadingViewModel Protocol
    var isLoading = false
    var loadingMessage: String?
    
    // MARK: - ThemesViewModelProtocol
    var themes: [Theme] = []
    var isLastPage = false
    var errorMessage: String?
    
    // MARK: - Private Properties
    private var currentPage = 1
    private let pageSize = 10
    private let service: ThemeServiceProtocol
    
    // MARK: - Task Management
    private var loadingTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(service: ThemeServiceProtocol = ThemeService.shared) {
        self.service = service
        setupNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Notification Observer Setup
extension PublicThemesViewModel {
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeCreated(_:)),
            name: .themeCreated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeUpdated(_:)),
            name: .themeUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeDeleted(_:)),
            name: .themeDeleted,
            object: nil
        )
    }
    
    @objc private func handleThemeCreated(_ notification: Notification) {
        guard let theme = notification.userInfo?[Notification.ThemeKeys.theme] as? Theme else { return }
        
        // 공개 테마만 추가
        if theme.isPublic {
            themes.insert(theme, at: 0)
            print("✅ PublicThemesViewModel: 새 공개 테마 추가 - \(theme.id)")
        }
    }
    
    @objc private func handleThemeUpdated(_ notification: Notification) {
        guard let updatedTheme = notification.userInfo?[Notification.ThemeKeys.theme] as? Theme else { return }
        let previousTheme = notification.userInfo?[Notification.ThemeKeys.previousTheme] as? Theme
        
        // 기존 테마가 목록에 있었는지 확인
        let wasInList = themes.contains { $0.id == updatedTheme.id }
        let shouldBeInList = updatedTheme.isPublic
        
        if wasInList && shouldBeInList {
            // 공개 상태이고 이미 목록에 있음 → 업데이트
            updateThemeInLocal(updatedTheme)
            print("✅ PublicThemesViewModel: 테마 업데이트 - \(updatedTheme.id)")
        } else if !wasInList && shouldBeInList {
            // 공개 상태이지만 목록에 없음 → 추가
            themes.insert(updatedTheme, at: 0)
            print("✅ PublicThemesViewModel: 비공개→공개로 변경된 테마 추가 - \(updatedTheme.id)")
        } else if wasInList && !shouldBeInList {
            // 목록에 있지만 더이상 공개가 아님 → 제거
            removeThemeFromLocal(themeId: updatedTheme.id)
            print("✅ PublicThemesViewModel: 공개→비공개로 변경된 테마 제거 - \(updatedTheme.id)")
        }
    }
    
    @objc private func handleThemeDeleted(_ notification: Notification) {
        guard let deletedThemeId = notification.userInfo?[Notification.ThemeKeys.deletedThemeId] as? String else { return }
        
        // 목록에서 제거
        removeThemeFromLocal(themeId: deletedThemeId)
        print("✅ PublicThemesViewModel: 테마 삭제 - \(deletedThemeId)")
    }
}

// MARK: - Core Reading Methods
extension PublicThemesViewModel {
    
    func loadThemes() async {
        // 이미 로딩 중이거나 마지막 페이지면 중단
        guard loadingTask == nil else { return }
        guard !isLastPage else { return }
        
        loadingTask = Task { @MainActor in
            await performLoadThemes()
        }
    }
    
    func refreshThemes() async {
        // 기존 로딩 취소
        cancelLoadingTask()
        
        // 상태 초기화
        currentPage = 1
        isLastPage = false
        themes = []
        
        // 새로 로드
        await loadThemes()
    }
    
    func loadMoreIfNeeded(currentItem: Theme?) async {
        guard shouldLoadMore(for: currentItem) else { return }
        await loadThemes()
    }
    
    func fetchSpecificTheme(themeId: String) async -> Theme? {
        isLoading = true
        loadingMessage = "테마를 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.fetchSpecificTheme(themeId: themeId)
            
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
    
    private func performLoadThemes() async {
        isLoading = true
        loadingMessage = "공개 테마를 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
            loadingTask = nil
        }
        
        do {
            let response = try await service.getAllThemes(
                page: currentPage,
                pageSize: pageSize
            )
            
            // Task 취소 확인
            try Task.checkCancellation()
            
            // 기존 데이터에 추가
            themes.append(contentsOf: response.data)
            
            // 페이지네이션 상태 업데이트
            isLastPage = response.pagination.currentPage >= response.pagination.totalPages
            if !isLastPage {
                currentPage += 1
            }
            
            print("✅ PublicThemesViewModel: \(response.data.count)개 공개 테마 로드 완료")
            
        } catch is CancellationError {
            return
        } catch {
            handleError(error)
        }
    }
}

// MARK: - Helper Methods
extension PublicThemesViewModel {
    
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    private func updateThemeInLocal(_ theme: Theme) {
        if let index = themes.firstIndex(where: { $0.id == theme.id }) {
            themes[index] = theme
        }
    }
    
    private func removeThemeFromLocal(themeId: String) {
        themes.removeAll { $0.id == themeId }
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
        print("❌ PublicThemesViewModel 에러: \(error)")
    }
}
