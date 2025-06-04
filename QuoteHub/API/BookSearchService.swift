//
//  BookSearchService.swift
//  QuoteHub
//
//  Created by 이융의 on 10/21/23.
//

import Foundation
import Combine
import Alamofire

class BookSearchService {
    func fetchBooksPublisher(query: String, page: Int) -> AnyPublisher<APIResponse<BooksResponse>, Error> {
        let endpoint = "?query=\(query)&page=\(page)"
        let urlString = APIEndpoint.searchBookURL + endpoint
        
        guard let url = URL(string: urlString) else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return Future<APIResponse<BooksResponse>, Error> { promise in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: APIResponse<BooksResponse>.self) { response in
                    switch response.result {
                    case .success(let booksResponse):
                        promise(.success(booksResponse))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchBooksAsync(query: String, page: Int) async throws -> APIResponse<BooksResponse> {
        let endpoint = "?query=\(query)&page=\(page)"
        let urlString = APIEndpoint.searchBookURL + endpoint
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get)
                .validate()
                .responseDecodable(of: APIResponse<BooksResponse>.self) { response in
                    switch response.result {
                    case .success(let booksResponse):
                        continuation.resume(returning: booksResponse)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    func getRandomBooks(completion: @escaping (Result<RandomBooksResponse, AFError>) -> Void) {
        let url = APIEndpoint.recommendBooksURL
        
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: RandomBooksResponse.self) { response in
                completion(response.result)
            }
    }

    enum APIError: Error {
        case invalidURL
        case noData
    }
}
