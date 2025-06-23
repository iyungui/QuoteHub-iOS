//
//  MyThemesViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

@MainActor
@Observable
final class MyThemesViewModel: EditableThemesViewModelProtocol {
    
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
    private var operationTasks: Set<Task<Theme?, Never>> = []
    private var deletionTask: Task<Bool, Never>?
    
    // MARK: - Initialization
    init(service: ThemeServiceProtocol = ThemeService.shared) {
        self.service = service
    }
}

// MARK: - Core Reading Methods
extension MyThemesViewModel {
    
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
        loadingMessage = "내 테마를 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
            loadingTask = nil
        }
        
        do {
            let response = try await service.getMyThemes(
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
            
            print("✅ MyThemesViewModel: \(response.data.count)개 테마 로드 완료")
            
        } catch is CancellationError {
            return
        } catch {
            handleError(error)
        }
    }
}

// MARK: - CRUD Methods (핵심 기능)
extension MyThemesViewModel {
    
    func createTheme(
        image: UIImage? = nil,
        name: String,
        description: String? = nil,
        isPublic: Bool
    ) async -> Theme? {
        let task = Task { @MainActor in
            await performCreateTheme(
                image: image,
                name: name,
                description: description,
                isPublic: isPublic
            )
        }
        
        operationTasks.insert(task)
        let result = await task.value
        operationTasks.remove(task)
        
        return result
    }
    
    func updateTheme(
        themeId: String,
        image: UIImage? = nil,
        name: String,
        description: String? = nil,
        isPublic: Bool
    ) async -> Theme? {
        let task = Task { @MainActor in
            await performUpdateTheme(
                themeId: themeId,
                image: image,
                name: name,
                description: description,
                isPublic: isPublic
            )
        }
        
        operationTasks.insert(task)
        let result = await task.value
        operationTasks.remove(task)
        
        return result
    }
    
    func deleteTheme(themeId: String) async -> Bool {
        deletionTask = Task { @MainActor in
            await performDeleteTheme(themeId: themeId)
        }
        
        let result = await (deletionTask?.value ?? false)
        return result
    }
    
    // MARK: - Private CRUD Implementation
    
    private func performCreateTheme(
        image: UIImage?,
        name: String,
        description: String?,
        isPublic: Bool
    ) async -> Theme? {
        isLoading = true
        loadingMessage = "테마를 생성하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.createTheme(
                image: image,
                name: name,
                description: description,
                isPublic: isPublic
            )
            
            try Task.checkCancellation()
            
            guard response.success, let newTheme = response.data else {
                errorMessage = response.message
                return nil
            }
            
            // 1. 자신의 로컬 데이터 즉시 업데이트
            themes.insert(newTheme, at: 0)
            
            // 2. 다른 뷰모델들에게 이벤트 발송
            NotificationCenter.default.post(
                name: .themeCreated,
                object: nil,
                userInfo: [Notification.ThemeKeys.theme: newTheme]
            )
            
            print("✅ 테마 생성 완료 - ID: \(newTheme.id)")
            return newTheme
            
        } catch is CancellationError {
            return nil
        } catch {
            handleError(error)
            return nil
        }
    }
    
    private func performUpdateTheme(
        themeId: String,
        image: UIImage?,
        name: String,
        description: String?,
        isPublic: Bool
    ) async -> Theme? {
        isLoading = true
        loadingMessage = "테마를 수정하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        // 수정 전 상태 저장 (이벤트용)
        let previousTheme = themes.first(where: { $0.id == themeId })
        
        do {
            let response = try await service.updateTheme(
                themeId: themeId,
                image: image,
                name: name,
                description: description,
                isPublic: isPublic
            )
            
            try Task.checkCancellation()
            
            guard let updatedTheme = response.data else {
                errorMessage = "테마 수정에 실패했습니다."
                return nil
            }
            
            // 1. 자신의 로컬 데이터 업데이트
            updateThemeInLocal(updatedTheme)
            
            // 2. 다른 뷰모델들에게 이벤트 발송
            var userInfo: [String: Any] = [Notification.ThemeKeys.theme: updatedTheme]
            if let previousTheme = previousTheme {
                userInfo[Notification.ThemeKeys.previousTheme] = previousTheme
            }
            NotificationCenter.default.post(
                name: .themeUpdated,
                object: nil,
                userInfo: userInfo
            )
            
            print("✅ 테마 수정 완료 - ID: \(updatedTheme.id)")
            return updatedTheme
            
        } catch is CancellationError {
            return nil
        } catch {
            handleError(error)
            return nil
        }
    }
    
    private func performDeleteTheme(themeId: String) async -> Bool {
        isLoading = true
        loadingMessage = "테마를 삭제하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            _ = try await service.deleteTheme(themeId: themeId)
            
            try Task.checkCancellation()
            
            // 1. 자신의 로컬 데이터에서 삭제
            removeThemeFromLocal(themeId: themeId)
            
            // 2. 다른 뷰모델들에게 이벤트 발송
            NotificationCenter.default.post(
                name: .themeDeleted,
                object: nil,
                userInfo: [Notification.ThemeKeys.deletedThemeId: themeId]
            )
            
            print("✅ 테마 삭제 완료 - ID: \(themeId)")
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
extension MyThemesViewModel {
    
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
        print("❌ MyThemesViewModel 에러: \(error)")
    }
}
