//
//  BookSearchService.swift
//  QuoteHub
//
//  Created by 이융의 on 10/21/23.
//

import Foundation
import Alamofire

class BookSearchService {
    func fetchBooks(query: String, page: Int, completion: @escaping (Result<APIResponse<BooksResponse>, Error>) -> Void) {
        
        let endpoint = "?query=\(query)&page=\(page)"
        let urlString = APIEndpoint.searchBookURL + endpoint
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        AF.request(url, method: .get)
            .validate()
            .responseDecodable(of: APIResponse<BooksResponse>.self) { response in
                switch response.result {
                case .success(let booksResponse):
                    completion(.success(booksResponse))
                case .failure(let error):
                    completion(.failure(error))
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
