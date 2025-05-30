//
//  CommentViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import Foundation
import SwiftUI

class CommentViewModel: ObservableObject {
    @Published var bookStoryComments = [BookStoryComment]()
    @Published var totalCommentCount = 0

    @Published var isLoading = false
    @Published var isLastPage = false

    private var page = 1
    private let pageSize = 10
    private var service = StoryCommentService()

    private var bookStoryId: String
    private var commentId: String?

    init(bookStoryId: String) {
        self.bookStoryId = bookStoryId
        loadComments()
        getCommentCount()
    }
    
    func refreshComments() {
        page = 1
        isLastPage = false
        isLoading = false
        bookStoryComments.removeAll()
        loadComments()
        getCommentCount()
    }
    
    func loadComments() {
        guard !isLoading && !isLastPage else { return }

        isLoading = true

        service.getCommentforStory(bookStoryId: bookStoryId, page: page, pageSize: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.bookStoryComments.append(contentsOf: response.data)
                    self?.isLastPage = response.pagination.currentPage >= response.pagination.totalPages
                    self?.page += 1
                    self?.isLoading = false
                case .failure(let error):
                    print("Error loading Comments List: \(error)")
                }
            }
        }
    }
    
    func loadMoreIfNeeded(currentItem item: BookStoryComment?) {
        guard let item = item else { return }

        if item == bookStoryComments.last {
            loadComments()
        }
    }
    
    func addCommentToStory(content: String, parentCommentId: String?, completion: @escaping (Result<BookStoryComment, Error>) -> Void) {
        service.addCommentToStory(bookStoryId: bookStoryId, content: content, parentCommentId: parentCommentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let postCommentResponse):
                    let newComment = BookStoryComment( 
                        _id: postCommentResponse.data!._id,
                        userId: postCommentResponse.data!.userId,
                        bookStoryId: self?.bookStoryId ?? "",
                        content: postCommentResponse.data!.content,
                        parentCommentId: postCommentResponse.data!.parentCommentId,
                        createdAt: postCommentResponse.data!.createdAt,
                        updatedAt: postCommentResponse.data!.updatedAt
                    )
                    self?.bookStoryComments.insert(newComment, at: 0)
                    self?.totalCommentCount += 1
                    completion(.success(newComment))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
    }

    
    func deleteCommentStory(commentId: String, completion: @escaping (Bool, String?) -> Void) {
        service.deleteCommentStory(commentId: commentId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if let index = self?.bookStoryComments.firstIndex(where: { $0.id == commentId}) {
                        self?.bookStoryComments.remove(at: index)
                    }
                    self?.totalCommentCount -= 1
                    completion(true, nil)
                case .failure(let error):
                    let errorMessage = error.asAFError?.responseCode == 403 ? "You do not have permission to delete this comment." : error.localizedDescription
                    completion(false, errorMessage)
                }
            }
        }
    }
    
    func getCommentCount() {
        service.getCommentCountForStory(bookStoryId: bookStoryId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard let data = response.data else {
                        print(#fileID, #function, #line, "- no data")
                        self?.totalCommentCount = 0
                        return
                    }
                    self?.totalCommentCount = data
                case .failure(let error):
                    print("Error fetching comment count: \(error)")
                }
            }
        }
    }
}

