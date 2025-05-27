//  
//  BooksViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 10/21/23.
//

import Foundation
import SwiftUI
import Combine

class BooksViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var error: Error?
    
    @Published var isEnd: Bool = false
    @Published var hasSearched: Bool = false
    private var currentPage: Int = 1
    
    let bookSearchService = BookSearchService()
    
    func resetCurrentPage() {
        self.currentPage = 1
    }
    
    func fetchBooks(query: String) {
        
        bookSearchService.fetchBooks(query: query, page: currentPage) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let booksResponse):
                    self?.hasSearched = true
                    if self?.currentPage == 1 {
                        self?.books = booksResponse.data!.documents
                    } else {
                        self?.books.append(contentsOf: booksResponse.data!.documents)
                    }
                    self?.isEnd = booksResponse.data!.meta.is_end
                    if !booksResponse.data!.meta.is_end {
                        self?.currentPage += 1
                    }
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}

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
