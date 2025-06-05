//  
//  BooksViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 10/21/23.
//

import Combine
import SwiftUI

class BooksViewModel: ObservableObject, LoadingViewModel {
    @Published var books: [Book] = []
    @Published var error: Error?
    
    
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var loadingMessage: String?
    @Published var hasSearched: Bool = false
    @Published var isEnd: Bool = false
    
    private var currentPage: Int = 1
    private var currentQuery: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let searchSubject = PassthroughSubject<String, Never>()
    
    let bookSearchService = BookSearchService()
    
    init() {
        setupSearchDebouncing()
    }
    
    func setupSearchDebouncing() {
        searchSubject
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty && query.count >= 2 {
                    self?.performSearch(with: query)
                }
            }
            .store(in: &cancellables)
    }
    
    func updateSearchQuery(_ query: String) {
        currentQuery = query
        if !query.isEmpty {
            searchSubject.send(query)
        } else {
            clearSearch()
        }
    }
    
    func clearSearch() {
        books.removeAll()
        hasSearched = false
        isEnd = false
        error = nil
        currentPage = 1
    }
    
    func performSearch() {
        guard !currentQuery.isEmpty else { return }
        performSearch(with: currentQuery)
    }
    private func performSearch(with query: String) {
        guard !isLoading else { return }
        clearSearch()
        currentQuery = query
        isLoading = true
        loadingMessage = "책을 검색하는 중..."
        
        fetchBooks(query: query, page: 1, isInitialSearch: true)
    }
    
    @MainActor
    func performSearchAsync() async {
        guard !currentQuery.isEmpty else { return }
        isLoading = true
        loadingMessage = "책을 검색하는 중..."
        
        do {
            let booksResponse = try await bookSearchService.fetchBooksAsync(query: currentQuery, page: 1)
            await handleSearchResponse(booksResponse, isInitialSearch: true)
        } catch {
            self.error = error
            loadingMessage = "검색 중 오류가 발생했습니다."
        }
        
        isLoading = false
        loadingMessage = nil
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard !isLoading && !isLoadingMore && !isEnd else { return }
        guard currentIndex >= books.count - 3 else { return } // 마지막 3개 항목에 도달했을 때
        
        loadMore()
    }
    
    private func loadMore() {
        guard !currentQuery.isEmpty && !isEnd else { return }
        
        isLoadingMore = true
        fetchBooks(query: currentQuery, page: currentPage, isInitialSearch: false)
    }
    
    private func fetchBooks(query: String, page: Int, isInitialSearch: Bool) {
        bookSearchService.fetchBooksPublisher(query: query, page: page)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    self?.isLoadingMore = false
                    self?.loadingMessage = nil
                    
                    if case .failure(let error) = completion {
                        self?.error = error
                        if isInitialSearch {
                            self?.loadingMessage = "검색 중 오류가 발생했습니다."
                        }
                    }
                },
                receiveValue: { [weak self] booksResponse in
                    Task { @MainActor in
                        await self?.handleSearchResponse(booksResponse, isInitialSearch: isInitialSearch)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    @MainActor
    private func handleSearchResponse(_ booksResponse: APIResponse<BooksResponse>, isInitialSearch: Bool) async {
        guard let documents = booksResponse.data?.documents else { return }
        
        hasSearched = true
        
        if isInitialSearch {
            books = documents
        } else {
            books.append(contentsOf: documents)
        }
        
        isEnd = booksResponse.data?.meta.is_end ?? true
        
        if !isEnd {
            currentPage += 1
        }
        
        isLoading = false
        isLoadingMore = false
        loadingMessage = nil
    }
}
