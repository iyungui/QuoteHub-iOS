//
//  RandomBooksViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import Foundation

class RandomBooksViewModel: ObservableObject, LoadingViewModel {
    @Published var loadingMessage: String?
    
    @Published var books = [Book]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var bookSearchService = BookSearchService()
    
    @MainActor
    func fetchRandomBooks() async {
        guard !isLoading else { return }
        
        self.isLoading = true
        
        do {
            let response = try await bookSearchService.getRandomBooks()
            
            if response.success, let books = response.data {
                self.books = books
            } else {
                print(#fileID, #function, #line, "- ")
                print("Boos Response is empty")
            }
        } catch {
            
        }
        
        isLoading = false
    }
}
