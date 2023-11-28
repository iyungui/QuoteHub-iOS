//
//  BookStoriesViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/02.
//

import SwiftUI
import Combine

class BookStoriesViewModel: ObservableObject {
    
    enum Mode {
        case `public`
        case myStories
        case friendStories(String)
    }
    
    @Published var bookStories = [BookStory]()
    @Published var isLoading = false
    @Published var isLastPage = false

    private var currentPage = 1
    private let pageSize = 10
    private var service = BookStoryService()
    private var cancellables = Set<AnyCancellable>()
    
    private var folderId: String?
    private var searchKeyword: String?
    private var mode: Mode

    init(folderId: String? = nil, searchKeyword: String? = nil, mode: Mode) {
        self.folderId = folderId
        self.searchKeyword = searchKeyword
        self.mode = mode
        loadBookStories()
    }
    
    func storyData(forId storyId: String) -> BookStory? {
        return bookStories.first { $0.id == storyId }
    }

    func refreshBookStories() {
        currentPage = 1
        isLastPage = false
        isLoading = false
        bookStories.removeAll()
        loadBookStories()
    }
    
    func updateSearchKeyword(_ keyword: String) {
        self.searchKeyword = keyword
    }
    
    func loadBookStories() {
        guard !isLoading && !isLastPage else { return }
        
        if searchKeyword?.isEmpty == true {
            return
        }
        isLoading = true
        
        let completion: (Result<BookStoriesResponse, Error>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.bookStories.append(contentsOf: response.data)
                    self?.isLastPage = response.currentPage >= response.totalPages
                    self?.currentPage += 1
                    self?.isLoading = false
                case .failure(let error):
                    print("Error loading book stories: \(error)")
                }
            }
        }
        
        switch mode {
        case .public:
            if let folderId = folderId {
                service.getAllStoriesByFolder(folderId: folderId, page: currentPage, pageSize: pageSize, completion: completion)
            } else if let searchKeyword = searchKeyword {
                service.getAllPublicStoriesKeyword(keyword: searchKeyword, page: currentPage, pageSize: pageSize, completion: completion)
            } else {
                service.fetchPublicBookStories(page: currentPage, pageSize: pageSize, completion: completion)
            }
        case .myStories:
            if let folderId = folderId {
                service.getMyStoriesByFolder(folderId: folderId, page: currentPage, pageSize: pageSize, completion: completion)
            } else if let searchKeyword = searchKeyword {
                service.getAllmyStoriesKeyword(keyword: searchKeyword, page: currentPage, pageSize: pageSize, completion: completion)
            } else {
                service.fetchMyBookStories(page: currentPage, pageSize: pageSize, completion: completion)
            }
        case .friendStories(let friendId):
            if let folderId = folderId {
                service.getFriendStoriesByFolder(folderId: folderId, friendId: friendId, page: currentPage, pageSize: pageSize, completion: completion)
            } else if let searchKeyword = searchKeyword {
                service.getAllFriendStoriesKeyword(friendId: friendId, keyword: searchKeyword, page: currentPage, pageSize: pageSize, completion: completion)
            } else {
                service.fetchFriendBookStories(friendId: friendId, page: currentPage, pageSize: pageSize, completion: completion)
            }
        }
    }
    
    func loadMoreIfNeeded(currentItem item: BookStory?) {
        guard let item = item else { return }

        if item == bookStories.last {
            loadBookStories()
        }
    }
    
    // MARK: - CREATE NEW STORY
    
    func createBookStory(images: [UIImage], bookId: String, quote: String, content: String, isPublic: Bool, keywords: [String], folderIds: [String], completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        service.createBookStory(images: images, bookId: bookId, quote: quote, content: content, isPublic: isPublic, keywords: keywords, folderIds: folderIds) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let bookStoryResponse):
                    self?.bookStories.insert(bookStoryResponse.data, at: 0)
                    self?.isLoading = false
                    completion(true)
                case .failure:
                    self?.isLoading = false
                    completion(false)
                }
            }
            
        }
    }
    
    // MARK: - DELETE MY STORY
    
    func deleteBookStory(storyID: String, completion: @escaping (Bool) -> Void) {
        service.deleteBookStory(storyID: storyID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if let index = self?.bookStories.firstIndex(where: { $0.id == storyID }) {
                        self?.bookStories.remove(at: index)
                    }
                    completion(true)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - UPDATE MY STORY
    
    func updateBookStory(storyID: String, images: [UIImage]?, quote: String?, content: String?, isPublic: Bool, keywords: [String]?, folderIds: [String]?, completion: @escaping (Bool) -> Void) {
        service.updateBookStory(storyID: storyID, images: images, quote: quote, content: content, isPublic: isPublic, keywords: keywords, folderIds: folderIds) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedStoryResponse):
                    if let index = self?.bookStories.firstIndex(where: { $0.id == storyID }) {
                        // Update the story in the array
                        self?.bookStories[index] = updatedStoryResponse.data
                    }
                    completion(true)
                case .failure(let error):
                    print("Error updating book story: \(error)")
                    completion(false)
                }
            }
        }
    }
}
