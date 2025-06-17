//
//  BookSearchService.swift
//  QuoteHub
//
//  Created by 이융의 on 10/21/23.
//

import Foundation

protocol BookSearchServiceProtocol {
    func fetchBooksAsync(query: String, page: Int) async throws -> APIResponse<BooksResponse>
    func getRandomBooks() async throws -> APIResponse<[Book]>
}

final class BookSearchService: BookSearchServiceProtocol {
    private let apiClient = APIClient.shared

    func fetchBooksAsync(query: String, page: Int) async throws -> APIResponse<BooksResponse> {
        print(#fileID, #function, #line, "- ")
        print("query: \(query), page: \(page)")
        return try await apiClient.request(
            endpoint: BookSearchEndpoints.searchBook(query: query, page: page),
            body: EmptyData(),
            responseType: APIResponse<BooksResponse>.self
        )
    }
    
    func getRandomBooks() async throws -> APIResponse<[Book]> {
        return try await apiClient.request(
            endpoint: BookSearchEndpoints.recommendBooks,
            body: EmptyData(),
            responseType: APIResponse<[Book]>.self
        )
    }
}
