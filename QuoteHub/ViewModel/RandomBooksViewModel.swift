//
//  RandomBooksViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import Foundation

@MainActor
@Observable
final class RandomBooksViewModel: LoadingViewModel {
    var loadingMessage: String?
    
    var books = [Book]()
    var isLoading = false
    var errorMessage: String?
    
    private var bookSearchService: BookSearchServiceProtocol
    
    init(bookSearchService: BookSearchServiceProtocol = BookSearchService()) {
        self.bookSearchService = bookSearchService
    }
    
    func fetchRandomBooks() async {
        guard !isLoading else { return }
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            let response = try await bookSearchService.getRandomBooks()
            
            
            if response.success, let books = response.data {
                self.books = books
            } else {
                print(#fileID, #function, #line, "- ")
                print("Boos Response is empty")
            }
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다.: \(error.localizedDescription)"
        }
    }
}
