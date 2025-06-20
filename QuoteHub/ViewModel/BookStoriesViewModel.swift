//
//  BookStoriesViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/02.
//

import SwiftUI

@MainActor  // 클래스의 모든 메서드와 프로퍼티가 메인 스레드에서 실행됨을 보장
@Observable // SwiftUI 뷰가 필요한 프로퍼티 변경시에만 리렌더링, 효율적
class BookStoriesViewModel: LoadingViewModel {
    // MARK: - LoadingViewModel Protocol
    var isLoading = false
    var loadingMessage: String?
    
    // MARK: - PUBLISHED PROPERTIES
    var storiesByType: [LoadType: [BookStory]] = [:]
    /// 페이지네이션(무한스크롤) 할 때 필요한 프로퍼티
    var isLastPage = false
    var errorMessage: String?
    
    // MARK: - PRIVATE PROPERTIES
    private var currentPage = 1
    private let pageSize = 10   // pageSize는 고정
    private let service: BookStoryServiceProtocol
    
    /// 테마 ID - 테마 ID가 있으면, 테마별 북스토리로 조회
    private var themeId: String?
    
    /// 검색 키워드 - 키워드가 있으면, 키워드별 북스토리로 조회
    private var searchKeyword: String?
    
    /// 현재 북스토리 로드 타입 (기본 my)
    private var currentStoryType: LoadType = .my

    // MARK: - TASK MANAGEMENT
    
    /// 각 LoadType(my, friend, public)별로 하나의 로딩 Task만 허용.
    /// 같은 타입의 데이터를 동시에 여러 번 로딩하지 않도록 방지
    private var loadingTasks: [LoadType: Task<Void, Never>] = [:]
    
    /// 생성/수정 작업들을 추적.
    /// Set을 사용해 완료된 Task는 자동으로 제거
    private var operationTasks: Set<Task<BookStory?, Never>> = []
    
    // 삭제 작업 (삭제는 Bool 값 리턴)
    private var deletionTasks: Task<Bool, Never>?
    
    
    // MARK: - Initialization
    init(service: BookStoryServiceProtocol = BookStoryService()) {
        self.service = service
    }
    
    // MARK: - PUBLIC METHODS
    
    /// 뷰에서 사용할 현재 타입의 북스토리들
    func bookStories(for type: LoadType) -> [BookStory] {
        return storiesByType[type] ?? []
    }
    
    /// 검색키워드 설정 및 관련 상태 초기화
    func setSearchKeyword(_ keyword: String?) {
        // 키워드가 변경되면 테마는 클리어
        if self.searchKeyword != keyword {
            self.themeId = nil
            self.searchKeyword = keyword
            clearAllData()
        }
    }
    
    /// 테마 ID 설정 및 관련 상태 초기화
    func setThemeId(_ themeId: String?) {
        // 테마가 변경되면 검색 키워드는 클리어
        if self.themeId != themeId {
            self.searchKeyword = nil
            self.themeId = themeId
            clearAllData()
        }
    }
    
    /// 모든 필터 클리어 (일반 북스토리 조회 모드)
    func clearAllFilters() {
        if self.themeId != nil || self.searchKeyword != nil {
            self.themeId = nil
            self.searchKeyword = nil
            clearAllData()
        }
    }
    
    /// 현재 설정된 필터 상태 확인
    var currentFilterMode: FilterMode {
        if let _ = themeId {
            return .theme
        } else if let _ = searchKeyword {
            return .search
        } else {
            return .none
        }
    }
    
    /// 새로고침 (북스토리 로드 타입 파라미터로 받음)
    func refreshBookStories(type: LoadType) {
        // 기존 로딩 Task 취소
        cancelLoadingTask(for: type)
        
        // 타입 변경
        currentStoryType = type
        
        // 페이지네이션 상태 초기화
        currentPage = 1
        isLastPage = false
        
        // 해당 타입의 데이터만 초기화 (만약 내 북스토리 리프레시면 내 북스토리 배열만 초기화됨)
        storiesByType[type] = []
        
        // 북스토리 로드
        loadBookStories(type: type)
    }
    
    // MARK: - LOAD STORIES
    
    /// 타입 바뀌면 상태 초기화하기,
    /// 빈 키워드일 경우 return,
    /// 테스크로딩중이거나 마지막페이지라면 return,
    /// task 생성 및 실행까지
    func loadBookStories(type: LoadType) {
        print(#fileID, #function, #line, "- ")
        
        // 타입이 바뀐 경우 상태 초기화
        if currentStoryType != type {
            print("로드 타입이 바뀜! ")
            /// 타입이 바뀌면 기존 로딩(예전 타입의 로딩)을 캔슬!
            cancelLoadingTask(for: currentStoryType)
            currentStoryType = type
            currentPage = 1
            isLastPage = false
        }
        
        // 이미 해당 타입의 북스토리를 로딩 중이 아니어야 하고,
        // 마지막 페이지가 아니어야 함
        guard loadingTasks[type] == nil else {
            print("로딩 테스크가 이미 있다!")
            return
        }
        
        guard !isLastPage else {
            print("마지막 페이지다!")
            return
        }
        
        // 키워드 검색의 경우 - 빈 키워드면 로드할 필요없으므로 return
        if searchKeyword?.isEmpty == true {
            print("검색어 없으므로 리턴")
            return
        }
        
        // 여기까지는, 타입만 업데이트되었거나 변화없음
        // 이제 로딩 Task 생성 및 실행!
        let task = Task { @MainActor in
            // MainActor에서 실행되는 북스토리 로드 테스크
            await performLoadBookStories(type: type)
        }
        
        // 해당 타입에 테스크 추가
        loadingTasks[type] = task
    }
    
    /// 로딩상태 설정 및 초기화,
    /// Task 실행(fetchBookStoriesForType)하고 await
    /// Task가 취소된 경우 바로 return
    /// 서버 응답을 로컬 북스토리에 업데이트
    private func performLoadBookStories(type: LoadType) async {
        isLoading = true
        loadingMessage = "북스토리를 불러오는 중..."
        clearErrorMessage()
        
        // 함수가 종료될 때 실행 (실패 및 취소하더라도 실행됨)
        defer {
            // 로딩 상태 초기화
            isLoading = false
            loadingMessage = nil
            // 해당 타입의 테스크 참조 제거
            loadingTasks[type] = nil
            // task는 함수가 종료될 때 이미 완료되었으므로 참조만 제거하면 됨.
        }
        
        do {
            let response = try await fetchBookStoriesForType(type)
            
            // Task가 취소되었는지 확인
            try Task.checkCancellation()
            
            // 기존 데이터에 추가
            var existingStories = storiesByType[type] ?? []
            existingStories.append(contentsOf: response.data)
            storiesByType[type] = existingStories
            
            // 페이지네이션 상태 업데이트
            isLastPage = response.pagination.currentPage >= response.pagination.totalPages
            if !isLastPage {
                currentPage += 1
            }
        } catch is CancellationError {
            // Task가 취소된 경우 - 아무것도 하지 않고 리턴
            return
        } catch {
            print("북스토리 로드 실패: type: \(type), error: \(error)")
            handleError(error)
        }
    }
     
    /// for Pagianation
    func loadMoreIfNeeded(currentItem item: BookStory?, type: LoadType) {
        print(#fileID, #function, #line, "- ")
        guard let item = item else { return }
        let stories = bookStories(for: type)
        
        // 현재 아이템이 배열의 마지막 아이템과 같은지 비교
        if item == stories.last {
            // 다음 페이지 로드
            loadBookStories(type: type)
        }
    }

    // MARK: - CREATE STORY
    
    func createBookStory(
        bookId: String,
        quotes: [Quote],
        images: [UIImage]?,
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?
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
            
            // 스토리를 관련 타입에 추가
            addStoryToTypes(newStory)
            print("북스토리 생성 완료")
            
            return newStory
            
        } catch is CancellationError {
            return nil
        } catch {
            print("북스토리 생성 실패 - \(error.localizedDescription)")
            handleError(error)
            return nil
        }
    }
    
    // MARK: - Update Story
    
    func updateBookStory(
        storyID: String,
        quotes: [Quote],
        images: [UIImage]?,
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?
    ) async -> BookStory? {
        let task = Task { @MainActor in
            await performUpdateBookStory(
                storyID: storyID,
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
    
    private func performUpdateBookStory(
        storyID: String,
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
        
        do {
            let response = try await service.updateBookStory(
                storyId: storyID,
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
            
            // 스토리 업데이트
            updateStoryInTypes(updatedStory)
            print("북스토리 업데이트 성공")
            return updatedStory
            
        } catch is CancellationError {
            return nil
        } catch {
            print("북스토리 업데이트 실패: \(error.localizedDescription)")
            errorMessage = "북스토리 수정 중 오류가 발생했습니다."
            return nil
        }
    }
    
    // MARK: - Delete Story
    
    func deleteBookStory(storyID: String) async -> Bool {
        deletionTasks = Task { @MainActor in
            await performDeleteBookStory(storyID: storyID)
        }
        
        let result = await (deletionTasks?.value ?? false)

        return result
    }
    
    private func performDeleteBookStory(storyID: String) async -> Bool {
        isLoading = true
        loadingMessage = "북스토리를 삭제하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            _ = try await service.deleteBookStory(storyId: storyID)
            
            try Task.checkCancellation()
            
            // 로컬에서 스토리 삭제
            removeStoryFromTypes(storyID: storyID)
            
            print("북스토리 삭제 성공")
            return true
            
        } catch is CancellationError {
            return false
        } catch {
            handleError(error)
            return false
        }
    }
    
    // MARK: - Fetch Specific Story
    
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
            
            try Task.checkCancellation()
            
            if response.success {
                return response.data    // BookStory?
            } else {
                errorMessage = response.message
                return nil
            }
        } catch is CancellationError {
            return nil
        } catch {
            handleError(error)
            return nil
        }
    }
}

// MARK: - FilterMode Enum
enum FilterMode {
    case none     // 일반 북스토리 조회
    case theme    // 테마별 조회
    case search   // 키워드별 조회
}

// MARK: - Private Helper Methods

private extension BookStoriesViewModel {
    
    /// 타입에 따른 북스토리 fetch
    func fetchBookStoriesForType(_ type: LoadType) async throws -> PaginatedAPIResponse<BookStory> {
        switch type {
        case .my:
            if let themeId = themeId {
                return try await service.fetchMyBookStoriesByTheme(
                    themeId: themeId,
                    page: currentPage,
                    pageSize: pageSize
                )
            } else if let searchKeyword = searchKeyword {
                return try await service.fetchMyBookStoriesByKeyword(
                    keyword: searchKeyword,
                    page: currentPage,
                    pageSize: pageSize
                )
            } else {
                return try await service.fetchMyBookStories(
                    page: currentPage,
                    pageSize: pageSize
                )
            }
            
        case .friend(let friendId):
            if let themeId = themeId {
                return try await service.fetchFriendBookStoriesByTheme(
                    themeId: themeId,
                    friendId: friendId,
                    page: currentPage,
                    pageSize: pageSize
                )
            } else if let searchKeyword = searchKeyword {
                return try await service.fetchFriendBookStoriesByKeyword(
                    friendId: friendId,
                    keyword: searchKeyword,
                    page: currentPage,
                    pageSize: pageSize
                )
            } else {
                return try await service.fetchFriendBookStories(
                    friendId: friendId,
                    page: currentPage,
                    pageSize: pageSize
                )
            }
            
        case .public:
            if let themeId = themeId {
                return try await service.fetchPublicBookStoriesByTheme(
                    themeId: themeId,
                    page: currentPage,
                    pageSize: pageSize
                )
            } else if let searchKeyword = searchKeyword {
                return try await service.fetchPublicBookStoriesByKeyword(
                    keyword: searchKeyword,
                    page: currentPage,
                    pageSize: pageSize
                )
            } else {
                return try await service.fetchPublicBookStories(
                    page: currentPage,
                    pageSize: pageSize
                )
            }
        }
    }
    
    /// 모든 데이터 및 상태 초기화
    func clearAllData() {
        // 모든 Task 취소
        cancelAllTasks()
        
        // 데이터 초기화
        storiesByType.removeAll()
        
        // 페이지네이션 상태 초기화
        currentPage = 1
        isLastPage = false
        
        // 에러 메시지 초기화
        clearErrorMessage()
    }
    
    /// 스토리를 my 타입과 (isPublic일 경우) public 타입에 추가
    func addStoryToTypes(_ story: BookStory) {
        // my 타입에 추가
        var myStories = storiesByType[.my] ?? []
        myStories.insert(story, at: 0)
        storiesByType[.my] = myStories
        
        // isPublic인 경우 .public에도 추가
        if story.isPublic {
            var publicStories = storiesByType[.public] ?? []
            publicStories.insert(story, at: 0)
            storiesByType[.public] = publicStories
        }
    }
    
    /// 스토리를 관련된 타입들에서 삭제 (북스토리 삭제/업데이트 시 사용)
    func removeStoryFromTypes(storyID: String) {
        for (type, stories) in storiesByType {
            var updatedStories = stories
            updatedStories.removeAll { $0.id == storyID }
            storiesByType[type] = updatedStories
        }
    }
    
    /// 스토리를 관련된 타입들에서 업데이트 (북스토리 업데이트 시 사용)
    func updateStoryInTypes(_ story: BookStory) {
        // 먼저 모든 타입에서 해당 스토리 제거
        removeStoryFromTypes(storyID: story.id)
        
        // 새로운 상태에 맞게 다시 추가
        addStoryToTypes(story)
    }
    
    /// 특정 타입의 로딩 Task 취소
    func cancelLoadingTask(for type: LoadType) {
        loadingTasks[type]?.cancel()
        loadingTasks[type] = nil
    }
    
    /// 모든 Task 취소
    func cancelAllTasks() {
        // 로딩 Task들 취소
        for task in loadingTasks.values {
            task.cancel()
        }
        loadingTasks.removeAll()
        
        // 작업 Task들 취소
        for task in operationTasks {
            task.cancel()
        }
        operationTasks.removeAll()
        
        deletionTasks?.cancel()
        deletionTasks = nil
    }
    
    /// 에러 메시지 초기화
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    /// 에러 처리
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
            print("북스토리 생성 실패오류: - \(String(describing: errorMessage))")
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다.: \(error.localizedDescription)"
            print("북스토리 생성 알수없는 실패오류: - \(String(describing: errorMessage))")
        }
    }
}
