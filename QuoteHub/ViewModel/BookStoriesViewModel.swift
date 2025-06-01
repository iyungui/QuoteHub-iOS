//
//  BookStoriesViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/02.
//

import SwiftUI

enum LoadType: Equatable {
    case my
    case friend(String) // friendID
    case `public`
}

class BookStoriesViewModel: ObservableObject {
    
    @Published var bookStories = [BookStory]()
    @Published var isLoading = false
    @Published var isLastPage = false
    @Published var errorMessage: String?

    private var currentPage = 1
    private let pageSize = 10
    private var service = BookStoryService()
    
    private var folderId: String?
    private var searchKeyword: String?
    
    private var currentStoryType: LoadType = .my

    init(folderId: String? = nil, searchKeyword: String? = nil) {
        self.folderId = folderId
        self.searchKeyword = searchKeyword
//        loadBookStories()
    }
    
    // TODO: - 사용하지 않는 메서드 제거
    func storyData(forId storyId: String) -> BookStory? {
        return bookStories.first { $0.id == storyId }
    }
    
    func updateSearchKeyword(_ keyword: String) {
        self.searchKeyword = keyword
    }

    /// 새로고침 (북스토리 타입 파라미터로 받음)
    func refreshBookStories(type: LoadType) {
        currentPage = 1
        isLastPage = false
        isLoading = false
        bookStories.removeAll()
        loadBookStories(type: type)
    }
    
    
    // MARK: - LOAD STORIES
    
    // TODO: - 단일 북스토리 조회 메서드 추가필요
    
    func loadBookStories(type: LoadType) {
        guard !isLoading && !isLastPage else { return }
        
        if searchKeyword?.isEmpty == true {
            return
        }
        isLoading = true
        currentStoryType = type
        
        let completion: (Result<BookStoriesResponse, Error>) -> Void = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.bookStories.append(contentsOf: response.data)
                    self.isLastPage = response.pagination.currentPage >= response.pagination.totalPages
                    self.currentPage += 1
                    self.isLoading = false
                case .failure(let error):
                    print("Error loading book stories (\(type)): \(error)")
                    self.isLoading = false
                }
            }
        }
        
        // 내 북스토리만, or 친구의 북스토리만 or 모든 사용자의 북스토리만 조회
        switch type {
        case .my:
            if let folderId = folderId {    // 테마에서 북스토리 조회하는 경우
                service.getMyStoriesByFolder(folderId: folderId, page: currentPage, pageSize: pageSize, completion: completion)
            } else if let searchKeyword = searchKeyword {   // 키워드로 북스토리 조회하는 경우
                service.getAllmyStoriesKeyword(keyword: searchKeyword, page: currentPage, pageSize: pageSize, completion: completion)
            } else {    // 내 북스토리 다 조회하기
                service.fetchMyBookStories(page: currentPage, pageSize: pageSize, completion: completion)
            }
        case .friend(let friendId):
            if let folderId = folderId {
                service.getFriendStoriesByFolder(folderId: folderId, friendId: friendId, page: currentPage, pageSize: pageSize, completion: completion)
            } else if let searchKeyword = searchKeyword {
                service.getAllFriendStoriesKeyword(friendId: friendId, keyword: searchKeyword, page: currentPage, pageSize: pageSize, completion: completion)
            } else {
                service.fetchFriendBookStories(friendId: friendId, page: currentPage, pageSize: pageSize, completion: completion)
            }
        case .public:
            if let folderId = folderId {
                service.getAllStoriesByFolder(folderId: folderId, page: currentPage, pageSize: pageSize, completion: completion)
            } else if let searchKeyword = searchKeyword {
                service.getAllPublicStoriesKeyword(keyword: searchKeyword, page: currentPage, pageSize: pageSize, completion: completion)
            } else {
                service.fetchPublicBookStories(page: currentPage, pageSize: pageSize, completion: completion)
            }
        }
    }
    
    /// for pagination
    func loadMoreIfNeeded(currentItem item: BookStory?) {
        guard let item = item else { return }

        if item == bookStories.last {
            loadBookStories(type: currentStoryType)
        }
    }
    
    
    // 여기서부터는 내 북스토리에 해당됨
    // MARK: - CREATE NEW STORY
    
    // TODO: 이미지 옵셔널로 변경
    func createBookStory(images: [UIImage], bookId: String, quote: String, content: String, isPublic: Bool, keywords: [String], folderIds: [String], completion: @escaping (Bool) -> Void) {
        print(#fileID, #function, #line, "- ")
        
        service.createBookStory(images: images, bookId: bookId, quote: quote, content: content, isPublic: isPublic, keywords: keywords, folderIds: folderIds) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = true

            DispatchQueue.main.async {
                switch result {
                case .success(let bookStoryResponse):
                    self.bookStories.insert(bookStoryResponse.data!, at: 0)    ///  로컬에서 바로 적용
                    self.isLoading = false
                    
                    print("북스토리 생성 완료")
                    completion(true)
                case .failure(let error):
                    self.isLoading = false
                    
                    print("북스토리 생성 실패 - \(error.localizedDescription)")
                    completion(false)
                }
            }
            
        }
    }
    
    // MARK: - DELETE MY STORY
    
    func deleteBookStory(storyID: String, completion: @escaping (Bool) -> Void) {
        print(#fileID, #function, #line, "- ")
        
        service.deleteBookStory(storyID: storyID) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = true
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    /// 해당 삭제된 북스토리를 로컬에서도 바로 삭제
                    if let index = self.bookStories.firstIndex(where: { $0.id == storyID }) {
                        self.bookStories.remove(at: index)
                    }
                    self.isLoading = false
                    
                    print("북스토리 삭제 성공")
                    completion(true)    // 함수 종료
                case .failure(let error):
                    self.isLastPage = false
                    
                    print("북스토리 삭제 실패 - \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - UPDATE MY STORY
    
    func updateBookStory(storyID: String, images: [UIImage]?, quote: String?, content: String?, isPublic: Bool, keywords: [String]?, folderIds: [String]?, completion: @escaping (Bool) -> Void) {
        print(#fileID, #function, #line, "- ")
        
        service.updateBookStory(storyID: storyID, images: images, quote: quote, content: content, isPublic: isPublic, keywords: keywords, folderIds: folderIds) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = true
            
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedStoryResponse):
                    if let index = self.bookStories.firstIndex(where: { $0.id == storyID }) {
                        // 해당 북스토리를 바로 업데이트
                        self.bookStories[index] = updatedStoryResponse.data!
                    }
                    
                    print("북스토리 업데이트 성공")
                    completion(true)
                    
                case .failure(let error):
                    
                    print("북스토리 업데이트 실패: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
}
