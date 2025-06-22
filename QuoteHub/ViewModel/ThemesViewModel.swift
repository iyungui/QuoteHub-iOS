////
////  ThemesViewModel.swift
////  QuoteHub
////
////  Created by 이융의 on 11/10/23.
////
//
//import SwiftUI
//
//@MainActor
//@Observable
//class ThemesViewModel: LoadingViewModel {
//    
//    // MARK: - LoadingViewModel Protocol
//    var isLoading = false
//    var loadingMessage: String?
//    
//    // MARK: - Published Properties
//    var themesByType: [LoadType: [Theme]] = [:]
//    var isLastPage = false
//    var errorMessage: String?
//    
//    // MARK: - Private Properties
//    private var currentPage = 1
//    private let pageSize = 10
//    private let service: ThemeServiceProtocol
//    private var currentThemeType: LoadType = .my
//    
//    // MARK: - Task Management
//    private var loadingTasks: [LoadType: Task<Void, Never>] = [:]
//    private var operationTasks: Set<Task<Theme?, Never>> = []
//    private var deletionTasks: Task<Bool, Never>?
//    
//    // MARK: - Initialization
//    init(service: ThemeServiceProtocol = ThemeService.shared) {
//        self.service = service
//    }
//    
//    // MARK: - Public Methods
//    
//    /// 뷰에서 사용할 현재 타입의 테마들
//    func themes(for type: LoadType) -> [Theme] {
//        return themesByType[type] ?? []
//    }
//    
//    /// 새로고침
//    func refreshThemes(type: LoadType) {
//        // 기존 로딩 Task 취소
//        cancelLoadingTask(for: type)
//        
//        // 타입 변경
//        currentThemeType = type
//        
//        // 페이지네이션 상태 초기화
//        currentPage = 1
//        isLastPage = false
//        
//        // 해당 타입의 데이터만 초기화
//        themesByType[type] = []
//        
//        // 테마 로드
//        loadThemes(type: type)
//    }
//    
//    // MARK: - Load Themes
//    
//    func loadThemes(type: LoadType) {
//        print(#fileID, #function, #line, "- ")
//        
//        // 타입이 바뀐 경우 상태 초기화
//        if currentThemeType != type {
//            print("로드 타입이 바뀜!")
//            cancelLoadingTask(for: currentThemeType)
//            currentThemeType = type
//            currentPage = 1
//            isLastPage = false
//        }
//        
//        // 이미 해당 타입의 테마를 로딩 중이 아니어야 하고,
//        // 마지막 페이지가 아니어야 함
//        guard loadingTasks[type] == nil else {
//            print("로딩 테스크가 이미 있다!")
//            return
//        }
//        
//        guard !isLastPage else {
//            print("마지막 페이지다!")
//            return
//        }
//        
//        // 로딩 Task 생성 및 실행
//        let task = Task { @MainActor in
//            await performLoadThemes(type: type)
//        }
//        
//        // 해당 타입에 테스크 추가
//        loadingTasks[type] = task
//    }
//    
//    private func performLoadThemes(type: LoadType) async {
//        isLoading = true
//        loadingMessage = "테마를 불러오는 중..."
//        clearErrorMessage()
//        
//        defer {
//            isLoading = false
//            loadingMessage = nil
//            loadingTasks[type] = nil
//        }
//        
//        do {
//            let response = try await fetchThemesForType(type)
//            
//            // Task가 취소되었는지 확인
//            try Task.checkCancellation()
//            
//            // 기존 데이터에 추가
//            var existingThemes = themesByType[type] ?? []
//            existingThemes.append(contentsOf: response.data)
//            themesByType[type] = existingThemes
//            
//            // 페이지네이션 상태 업데이트
//            isLastPage = response.pagination.currentPage >= response.pagination.totalPages
//            if !isLastPage {
//                currentPage += 1
//            }
//            
//        } catch is CancellationError {
//            return
//        } catch {
//            print("테마 로드 실패: type: \(type), error: \(error)")
//            handleError(error)
//        }
//    }
//    
//    /// for Pagination
//    func loadMoreIfNeeded(currentItem item: Theme?, type: LoadType) {
//        print(#fileID, #function, #line, "- ")
//        guard let item = item else { return }
//        let themes = themes(for: type)
//        
//        // 현재 아이템이 배열의 마지막 아이템과 같은지 비교
//        if item == themes.last {
//            // 다음 페이지 로드
//            loadThemes(type: type)
//        }
//    }
//    
//    // MARK: - Create Theme
//    
//    func createTheme(
//        image: UIImage?,
//        name: String,
//        description: String?,
//        isPublic: Bool
//    ) async -> Theme? {
//        let task = Task { @MainActor in
//            await performCreateTheme(
//                image: image,
//                name: name,
//                description: description,
//                isPublic: isPublic
//            )
//        }
//        
//        operationTasks.insert(task)
//        let result = await task.value
//        operationTasks.remove(task)
//        
//        return result
//    }
//    
//    private func performCreateTheme(
//        image: UIImage?,
//        name: String,
//        description: String?,
//        isPublic: Bool
//    ) async -> Theme? {
//        isLoading = true
//        loadingMessage = "테마를 생성하는 중..."
//        clearErrorMessage()
//        
//        defer {
//            isLoading = false
//            loadingMessage = nil
//        }
//        
//        do {
//            let response = try await service.createTheme(
//                image: image,
//                name: name,
//                description: description,
//                isPublic: isPublic
//            )
//            
//            try Task.checkCancellation()
//            
//            guard response.success, let newTheme = response.data else {
//                errorMessage = response.message
//                return nil
//            }
//            
//            // 테마를 관련 타입에 추가
//            addThemeToTypes(newTheme)
//            print("테마 생성 완료")
//            
//            return newTheme
//            
//        } catch is CancellationError {
//            return nil
//        } catch {
//            print("테마 생성 실패 - \(error.localizedDescription)")
//            handleError(error)
//            return nil
//        }
//    }
//    
//    // MARK: - Update Theme
//    
//    func updateTheme(
//        themeId: String,
//        image: UIImage?,
//        name: String,
//        description: String?,
//        isPublic: Bool
//    ) async -> Theme? {
//        let task = Task { @MainActor in
//            await performUpdateTheme(
//                themeId: themeId,
//                image: image,
//                name: name,
//                description: description,
//                isPublic: isPublic
//            )
//        }
//        
//        operationTasks.insert(task)
//        let result = await task.value
//        operationTasks.remove(task)
//        
//        return result
//    }
//    
//    private func performUpdateTheme(
//        themeId: String,
//        image: UIImage?,
//        name: String,
//        description: String?,
//        isPublic: Bool
//    ) async -> Theme? {
//        isLoading = true
//        loadingMessage = "테마를 수정하는 중..."
//        clearErrorMessage()
//        
//        defer {
//            isLoading = false
//            loadingMessage = nil
//        }
//        
//        do {
//            let response = try await service.updateTheme(
//                themeId: themeId,
//                image: image,
//                name: name,
//                description: description,
//                isPublic: isPublic
//            )
//            
//            try Task.checkCancellation()
//            
//            guard let updatedTheme = response.data else {
//                errorMessage = "테마 수정에 실패했습니다."
//                return nil
//            }
//            
//            // 테마 업데이트
//            updateThemeInTypes(updatedTheme)
//            print("테마 업데이트 성공")
//            return updatedTheme
//            
//        } catch is CancellationError {
//            return nil
//        } catch {
//            print("테마 업데이트 실패: \(error.localizedDescription)")
//            handleError(error)
//            return nil
//        }
//    }
//    
//    // MARK: - Delete Theme
//    
//    func deleteTheme(themeId: String) async -> Bool {
//        deletionTasks = Task { @MainActor in
//            await performDeleteTheme(themeId: themeId)
//        }
//        
//        let result = await (deletionTasks?.value ?? false)
//        return result
//    }
//    
//    private func performDeleteTheme(themeId: String) async -> Bool {
//        isLoading = true
//        loadingMessage = "테마를 삭제하는 중..."
//        clearErrorMessage()
//        
//        defer {
//            isLoading = false
//            loadingMessage = nil
//        }
//        
//        do {
//            _ = try await service.deleteTheme(themeId: themeId)
//            
//            try Task.checkCancellation()
//            
//            // 로컬에서 테마 삭제
//            removeThemeFromTypes(themeId: themeId)
//            
//            print("테마 삭제 성공")
//            return true
//            
//        } catch is CancellationError {
//            return false
//        } catch {
//            handleError(error)
//            return false
//        }
//    }
//}
//
//// MARK: - Private Helper Methods
//
//private extension ThemesViewModel {
//    
//    /// 타입에 따른 테마 fetch
//    func fetchThemesForType(_ type: LoadType) async throws -> PaginatedAPIResponse<Theme> {
//        switch type {
//        case .my:
//            return try await service.getMyThemes(
//                page: currentPage,
//                pageSize: pageSize
//            )
//        case .friend(let friendId):
//            return try await service.getUserThemes(
//                userId: friendId,
//                page: currentPage,
//                pageSize: pageSize
//            )
//        case .public:
//            return try await service.getAllThemes(
//                page: currentPage,
//                pageSize: pageSize
//            )
//        }
//    }
//    
//    /// 테마를 my 타입과 (isPublic일 경우) public 타입에 추가
//    func addThemeToTypes(_ theme: Theme) {
//        // my 타입에 추가
//        var myThemes = themesByType[.my] ?? []
//        myThemes.insert(theme, at: 0)
//        themesByType[.my] = myThemes
//        
//        // isPublic인 경우 .public에도 추가
//        if theme.isPublic {
//            var publicThemes = themesByType[.public] ?? []
//            publicThemes.insert(theme, at: 0)
//            themesByType[.public] = publicThemes
//        }
//    }
//    
//    /// 테마를 관련된 타입들에서 삭제
//    func removeThemeFromTypes(themeId: String) {
//        for (type, themes) in themesByType {
//            var updatedThemes = themes
//            updatedThemes.removeAll { $0.id == themeId }
//            themesByType[type] = updatedThemes
//        }
//    }
//    
//    /// 테마를 관련된 타입들에서 업데이트
//    func updateThemeInTypes(_ theme: Theme) {
//        // 먼저 모든 타입에서 해당 테마 제거
//        removeThemeFromTypes(themeId: theme.id)
//        
//        // 새로운 상태에 맞게 다시 추가
//        addThemeToTypes(theme)
//    }
//    
//    /// 특정 타입의 로딩 Task 취소
//    func cancelLoadingTask(for type: LoadType) {
//        loadingTasks[type]?.cancel()
//        loadingTasks[type] = nil
//    }
//    
//    /// 에러 메시지 초기화
//    func clearErrorMessage() {
//        errorMessage = nil
//    }
//    
//    /// 에러 처리
//    func handleError(_ error: Error) {
//        if let networkError = error as? NetworkError {
//            errorMessage = networkError.localizedDescription
//        } else {
//            errorMessage = "알 수 없는 오류가 발생했습니다.: \(error.localizedDescription)"
//        }
//    }
//}
