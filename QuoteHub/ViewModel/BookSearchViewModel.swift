//  
//  BookSearchViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 10/21/23.
//

import SwiftUI

@MainActor
@Observable
class BookSearchViewModel: LoadingViewModel {
    var books: [Book] = []
    
    // TODO: - isLoading 필요없는 것 같다
    var isLoading: Bool = false
    var loadingMessage: String?
    
    var isLoadingMore: Bool = false
    /// 실제로 검색을 했는지 여부 (검색 결과가 없을 시 사용)
    var hasSearched: Bool = false {
        didSet {
            print("HASSEARCHED: \(hasSearched)")
        }
    }
    var isEnd: Bool = false
    
    private var currentPage: Int = 1
    private var currentQuery: String = ""

    private let bookSearchService: BookSearchService
    
    init() {
        self.bookSearchService = BookSearchService()
    }
    
    // MARK: - Search Methods
    
    func updateQuery(_ query: String) {
        currentQuery = query
    }
    
    /// books 초기화, 상태 초기화
    func clearSearch() {
        books.removeAll()
        hasSearched = false
        isEnd = false
        currentPage = 1
    }
    
    /// 로딩 상태 초기화
    func resetLoadingStatus() {
        isLoading = false
        isLoadingMore = false
        loadingMessage = nil
    }
    
    func performSearchAsync() async {
        // 로딩중이라면 바로 return
        guard !isLoading else { return }
        
        // query가 빈 문자열이라면 return
        guard !currentQuery.isEmpty else { return }
        
        // 로딩 활성화
        isLoading = true
        loadingMessage = "책을 검색하는 중..."
        
        await fetchBooks(query: currentQuery, page: 1, isInitialSearch: true)
    }
    
    /// 책 검색 네트워크 요청 및 response handle 요청
    private func fetchBooks(query: String, page: Int, isInitialSearch: Bool) async {
        do {
            // API 호출은 URLSession 즉 백그라운드 스레드에서 실행
            let booksResponse = try await bookSearchService.fetchBooksAsync(query: query, page: page)
            
            // UI 업데이트는 메인 스레드에서 (업데이트 기다리기)
            await handleSearchResponse(booksResponse, isInitialSearch)
        } catch {
            // 에러 처리도 메인스레드에서
            resetLoadingStatus()
        }
    }
    
    /// search book response handling
    private func handleSearchResponse(_ booksResponse: APIResponse<BooksResponse>, _ isInitialSearch: Bool) async {
        guard let booksData = booksResponse.data else {
            // 서버에서 받은 data 자체가 nil일 때 처리
            hasSearched = true
            resetLoadingStatus()
            return
        }
        
        // 해당하는 책 검색 결과 없으면 여기로 옴(nil은 아님)
        
        hasSearched = true
        
        // 해당 query에 대해 처음 요청일 때 (page가 1일 때)
        if isInitialSearch {
            print("처음요청이야. 북에 할당해")
            books = booksData.documents
        } else {    // 기존 books 에 새 검색 응답 데이터 추가
            print("처음 요청이 아니야. 기존 북에 추가해")
            books.append(contentsOf: booksData.documents)
        }
        
        // 해당 챔 검색에 대한 isEnd 정보 업데이트
        isEnd = booksData.meta.is_end
        
        // 만약 마지막 페이지가 아니라면
        if !isEnd {
            currentPage += 1
        }
        
        resetLoadingStatus()
    }
    
    // MARK: - Pagination Methods
    
    func loadMoreIfNeeded(currentIndex: Int) async {
        // 로딩중이 아니고(작업중이 아니고), 추가 요청 없었고, 마지막 페이지 아닐 때
        guard !isLoading && !isLoadingMore && !isEnd else { return }
        // 해당 페이지의 검색결과의 마지막 3개 항목에 도달했을 때
        guard currentIndex >= books.count - 3 else { return }
        
        await loadMore()
    }
    
    private func loadMore() async {
//        print(#fileID, #function, #line, "- ")
        
        // !isEnd 이면 마지막 페이지 아니므로 다음 요청해야하고
        // currentQuery가 빈 문자열이 아니므로 다음 요청해야하고
        // isLoadingMore가 false 이므로 추가 로딩 작업중이 아닐 때.
        guard !currentQuery.isEmpty && !isEnd && !isLoadingMore else { return }
        
        print("loadMore 진짜 실행")
        
        isLoadingMore = true
        await fetchBooks(query: currentQuery, page: currentPage, isInitialSearch: false)
    }
}
