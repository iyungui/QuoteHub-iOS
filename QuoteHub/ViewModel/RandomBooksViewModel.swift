//
//  RandomBooksViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import Foundation

class RandomBooksViewModel: ObservableObject {
    @Published var books = [Book]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasLoadedOnce = false
    
    private var bookSearchService = BookSearchService()
    
    func getRandomBooksIfNeeded() {
        if !hasLoadedOnce {
            getRandomBooks()
            hasLoadedOnce = true
        }
    }
    
    func getRandomBooks() {
        self.isLoading = true
        bookSearchService.getRandomBooks { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    self?.books = response.data!
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
