//
//  BookStoriesViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/02.
//

import SwiftUI

enum LoadType: Equatable, Hashable {
    case my
    case friend(String) // friendID
    case `public`
}

class BookStoriesViewModel: ObservableObject, LoadingViewModel {
    // MARK: - LoadingViewModel Protocol
    @Published var isLoading = false
    @Published var loadingMessage: String?
    
    // MARK: - PROPERTIES
    @Published var storiesByType: [LoadType: [BookStory]] = [:]
    @Published var isLastPage = false
    @Published var errorMessage: String?

    /// 북스토리 생성, 수정 후 해당 북스토리로 navigation 하기 위한 프로퍼티
    @Published var lastCreatedStory: BookStory?
    
    private var currentPage = 1
    private let pageSize = 10
    private var service = BookStoryService()
    
    private var themeId: String?
    private var searchKeyword: String?
    
    private var currentStoryType: LoadType = .my

    init(themeId: String? = nil, searchKeyword: String? = nil) {
        self.themeId = themeId
        self.searchKeyword = searchKeyword
    }
    
    // 뷰에서 사용할 현재 타입의 북스토리들
    func bookStories(for type: LoadType) -> [BookStory] {
        return storiesByType[type] ?? []
    }
    
    func updateSearchKeyword(_ keyword: String) {
        self.searchKeyword = keyword
    }

    /// 새로고침 (북스토리 타입 파라미터로 받음)
    func refreshBookStories(type: LoadType) {
        currentStoryType = type
        currentPage = 1
        isLastPage = false
        isLoading = false
        
        // 해당 타입의 데이터만 초기화
        storiesByType[type] = []
        loadBookStories(type: type)
    }
    
    // MARK: - LOAD STORIES
    
    func loadBookStories(type: LoadType) {
        print(#fileID, #function, #line, "- ")
        
        // 타입이 바뀐 경우 상태 초기화
        if currentStoryType != type {
            currentStoryType = type
            currentPage = 1
            isLastPage = false
            isLoading = false
        }
        
        guard !isLoading && !isLastPage else { return }
        
        if searchKeyword?.isEmpty == true {
            return
        }
        
        isLoading = true
        loadingMessage = "북스토리를 불러오는 중..."
                
        let completion: (Result<BookStoriesResponse, Error>) -> Void = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // 해당 타입의 기존 데이터에 추가
                    var existingStories = self.storiesByType[type] ?? []
                    existingStories.append(contentsOf: response.data)
                    self.storiesByType[type] = existingStories
                    
                    self.isLastPage = response.pagination.currentPage >= response.pagination.totalPages
                    self.currentPage += 1
                    
//                    sleep(1)
                    self.isLoading = false
                    self.loadingMessage = nil
                case .failure(let error):
                    print("Error loading book stories (\(type)): \(error)")
                    self.isLoading = false
                    self.loadingMessage = nil
                    self.errorMessage = "북스토리를 불러오는 중 오류가 발생했습니다."
                }
            }
        }
        
        // 내 북스토리만, or 친구의 북스토리만 or 모든 사용자의 북스토리만 조회
        switch type {
        case .my:
            if let themeId = themeId {    // 테마에서 북스토리 조회하는 경우
                service.getMyStoriesByFolder(folderId: themeId, page: currentPage, pageSize: pageSize, completion: completion)
            } else if let searchKeyword = searchKeyword {   // 키워드로 북스토리 조회하는 경우
                service.getAllmyStoriesKeyword(keyword: searchKeyword, page: currentPage, pageSize: pageSize, completion: completion)
            } else {    // 내 북스토리 다 조회하기
                service.fetchMyBookStories(page: currentPage, pageSize: pageSize, completion: completion)
            }
        case .friend(let friendId):
            if let themeId = themeId {
                service.getFriendStoriesByFolder(folderId: themeId, friendId: friendId, page: currentPage, pageSize: pageSize, completion: completion)
            } else if let searchKeyword = searchKeyword {
                service.getAllFriendStoriesKeyword(friendId: friendId, keyword: searchKeyword, page: currentPage, pageSize: pageSize, completion: completion)
            } else {
                service.fetchFriendBookStories(friendId: friendId, page: currentPage, pageSize: pageSize, completion: completion)
            }
        case .public:
            if let themeId = themeId {
                service.getAllStoriesByFolder(folderId: themeId, page: currentPage, pageSize: pageSize, completion: completion)
            } else if let searchKeyword = searchKeyword {
                service.getAllPublicStoriesKeyword(keyword: searchKeyword, page: currentPage, pageSize: pageSize, completion: completion)
            } else {
                service.fetchPublicBookStories(page: currentPage, pageSize: pageSize, completion: completion)
            }
        }
    }
    
    /// for pagination
    func loadMoreIfNeeded(currentItem item: BookStory?, type: LoadType) {
        print(#fileID, #function, #line, "- ")
        guard let item = item else { return }
        let stories = bookStories(for: type)
        
        if item == stories.last {
            loadBookStories(type: type)
        }
    }
    
    // MARK: - HELPER METHODS FOR MULTI TYPE UPDATES
    
    // 스토리를 my 타입과 (isPublic일 경우) public 타입에 추가하는 메서드
    private func addStoryToTypes(_ story: BookStory) {
        // my 타입에 추가
        var myStories = storiesByType[.my] ?? []
        myStories.insert(story, at: 0)
        storiesByType[.my] = myStories
        
        // isPublic인 경우 .public에도 추가 -- 스토리 추가하면 홈뷰에도 바로뜨도록
        if story.isPublic {
            var publicStories = storiesByType[.public] ?? []
            publicStories.insert(story, at: 0)
            storiesByType[.public] = publicStories
        }
    }
    
    // 스토리를 관련된 타입들에서 삭제
    private func removeStoryFromTypes(storyID: String) {
        // 모든 타입에서 해당 스토리 삭제
        for (type, stories) in storiesByType {
            var updatedStories = stories
            updatedStories.removeAll { $0.id == storyID }
            storiesByType[type] = updatedStories
        }
    }
    
    // 스토리를 관련된 타입들에서 업데이트
    private func updateStoryInTypes(_ story: BookStory) {
        // 먼저 모든 타입에서 해당 스토리 제거 -> O(n)
        removeStoryFromTypes(storyID: story.id)
        
        // 새로운 상태에 맞게 다시 추가 (0번째에 다시 추가함. 만약 이번에 isPublic이 아니면, public 타입에는 추가되지 않음)
        addStoryToTypes(story)
    }
    
    // MARK: - CREATE NEW STORY
    
    func createBookStory(
        bookId: String,
        quotes: [Quote],
        images: [UIImage]?,
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?,
        completion: @escaping (Bool) -> Void
    ) {
        print(#fileID, #function, #line, "- ")
        
        isLoading = true
        loadingMessage = "북스토리를 등록하는 중..."
        
        service.createBookStory(
            images: images,
            bookId: bookId,
            quotes: quotes,
            content: content,
            isPublic: isPublic,
            keywords: keywords,
            themeIds: themeIds
        ) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let bookStoryResponse):
                    guard let newStory = bookStoryResponse.data else {
                        self.isLoading = false
                        self.loadingMessage = nil
                        completion(false)
                        return
                    }
                    
                    // (my 타입과 공개인 경우 public 타입에 새 스토리 추가하기)
                    self.addStoryToTypes(newStory)
                    self.lastCreatedStory = newStory
                    
                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    print("북스토리 생성 완료")
                    completion(true)
                case .failure(let error):
                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    print("북스토리 생성 실패 - \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - DELETE MY STORY
    
    func deleteBookStory(storyID: String, completion: @escaping (Bool) -> Void) {
        print(#fileID, #function, #line, "- ")
        
        isLoading = true
        loadingMessage = "북스토리를 삭제하는 중..."
        
        service.deleteBookStory(storyID: storyID) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    /// 해당 삭제된 북스토리를 로컬에서도 바로 삭제
                    
                    // 모든 타입에서 해당 스토리 삭제 (my + public)
                    self.removeStoryFromTypes(storyID: storyID)
                    
                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    print("북스토리 삭제 성공")
                    completion(true)    // 함수 종료
                case .failure(let error):
                    self.isLoading = false
                    self.loadingMessage = nil
                    self.isLastPage = false
                    
                    print("북스토리 삭제 실패 - \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - UPDATE MY STORY
    
    func updateBookStory(
        storyID: String,
        quotes: [Quote],
        images: [UIImage]?,
        content: String?,
        isPublic: Bool,
        keywords: [String]?,
        themeIds: [String]?,
        completion: @escaping (Bool) -> Void
    ) {
        print(#fileID, #function, #line, "- ")
        
        isLoading = true
        loadingMessage = "북스토리를 수정하는 중..."
        
        service.updateBookStory(
            storyID: storyID,
            quotes: quotes,
            images: images,
            content: content,
            isPublic: isPublic,
            keywords: keywords,
            themeIds: themeIds
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedStoryResponse):
                    guard let updatedStory = updatedStoryResponse.data else {
                        self.isLoading = false
                        self.loadingMessage = nil
                        completion(false)
                        return
                    }
                    
                    // 관련된 타입에서 스토리 업데이트
                    self.updateStoryInTypes(updatedStory)
                    self.lastCreatedStory = updatedStory
                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    print("북스토리 업데이트 성공")
                    completion(true)
                    
                case .failure(let error):
                    self.isLoading = false
                    self.loadingMessage = nil
                
                    print("북스토리 업데이트 실패: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
}

extension BookStoriesViewModel {
    
    // MARK: - FETCH SPECIFIC STORY
    
    func fetchSpecificBookStory(storyId: String, completion: @escaping (Result<BookStory, Error>) -> Void) {
        print(#fileID, #function, #line, "- ")
        
        isLoading = true
        loadingMessage = "북스토리를 불러오는 중..."
        
        service.fetchSpecificBookStory(storyId: storyId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let bookStoryResponse):
                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    if let story = bookStoryResponse.data {
                        completion(.success(story))
                    } else {
                        let error = NSError(domain: "BookStoriesViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Story data not found"])
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    print("북스토리 로드 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
}
