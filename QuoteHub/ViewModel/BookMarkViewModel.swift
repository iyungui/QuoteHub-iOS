//////
//////  BookMarkViewModel.swift
//////  QuoteHub
//////
//////  Created by 이융의 on 11/15/23.
//////
////
//import Foundation
//import Combine
//
//class BookMarkViewModel: ObservableObject {
//    @Published var bookMarks = [BookMark]()
//    @Published var isLoading = false
//    @Published var isLastPage = false
//    @Published var errorMessage: String?
//    @Published var isBookmarked: Bool = false
//    
//    private var currentPage = 1
//    private let pageSize = 10
//    private var service = BookMarkService()
//    private var cancellables = Set<AnyCancellable>()
//    
//    private var bookStoryId: String?
//    
//    init(bookStoryId: String? = nil) {
//        self.bookStoryId = bookStoryId
//        loadBookMarks()
//    }
//    
//    func updateIsBookmarked() {
//        isBookmarked = bookMarks.contains { $0.id == bookStoryId }
//    }
//    
//    func refreshBookMarks() {
//        currentPage = 1
//        isLastPage = false
//        isLoading = false
//        bookMarks.removeAll()
//        loadBookMarks()
//    }
//    
//    func loadBookMarks() {
//        guard !isLoading && !isLastPage else { return }
//
//        isLoading = true
//
//        service.getUserBookmarks(page: currentPage, pageSize: pageSize) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self?.bookMarks.append(contentsOf: response.data)
//                    self?.isLastPage = response.currentPage >= response.totalPages
//                    self?.updateIsBookmarked()
//
//                    self?.currentPage += 1
//                    self?.isLoading = false
//                case .failure(let error):
//                    print("Error loading BookMark List: \(error)")
//                    self?.errorMessage = error.localizedDescription
//                    self?.isLoading = false
//                }
//            }
//        }
//    }
//    
//    func loadMoreIfNeeded(currentItem item: BookMark?) {
//        guard let item = item else { return }
//
//        if item == bookMarks.last {
//            loadBookMarks()
//        }
//    }
//    
//    func createBookmark() {
//        print("Creating bookmark for \(bookStoryId ?? "")")
//        isLoading = true
//        service.createBookmark(bookStoryId: bookStoryId) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success(let bookMarkResponse):
//                    self?.updateIsBookmarked()
//                    self?.bookMarks.append(bookMarkResponse.data)
//                    self?.errorMessage = nil
//                    print("Bookmark created successfully. Current bookmarks: \(self?.bookMarks.count ?? 0)")
//                case .failure(let error as NSError):
//                    self?.errorMessage = error.userInfo[NSLocalizedDescriptionKey] as? String ?? "Error occurred"
//                    print("Failed to create bookmark: \(self?.errorMessage ?? "")")
//                }
//            }
//        }
//    }
//
//    func deleteBookmark() {
//        print("Deleting bookmark for \(bookStoryId ?? "")")
//        isLoading = true
//        service.deleteBookMark(bookStoryId: bookStoryId) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success:
//                    self?.updateIsBookmarked()
//                    self?.bookMarks.removeAll { $0.id == self?.bookStoryId }
//                    self?.errorMessage = nil
//                    print("Bookmark deleted successfully. Current bookmarks: \(self?.bookMarks.count ?? 0)")
//                case .failure(let error as NSError):
//                    self?.errorMessage = error.userInfo[NSLocalizedDescriptionKey] as? String ?? "Error occurred"
//                    print("Failed to delete bookmark: \(self?.errorMessage ?? "")")
//                }
//            }
//        }
//    }
//
//}
