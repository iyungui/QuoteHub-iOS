////
////  BookMarkService.swift
////  QuoteHub
////
////  Created by 이융의 on 11/15/23.
////
//
//import Foundation
//import Alamofire
//
//class BookMarkService {
//
//    func createBookmark(bookStoryId: String?, completion: @escaping (Result<BookMarkResponse, Error>) -> Void) {
//        
//        guard let bookStoryId = bookStoryId, let url = URL(string: APIEndpoint.createBookmarkURL + "/\(bookStoryId)") else {
//            completion(.failure(NSError(domain: "BookMarkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid book story ID or URL"])))
//            return
//        }
//        
//        guard let token = KeyChain.read(key: "JWTAccessToken") else {
//            completion(.failure(NSError(domain: "BookMarkService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
//            return
//        }
//        
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//        
//        AF.request(url, method: .post, headers: headers)
//            .responseDecodable(of: BookMarkResponse.self) { response in
//                switch response.result {
//                case .success(let bookMarkResponse):
//                    completion(.success(bookMarkResponse))
//                case .failure:
//                    if let statusCode = response.response?.statusCode {
//                        switch statusCode {
//                        case 400:
//                            completion(.failure(NSError(domain: "BookMarkService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid book story ID"])))
//                        case 404:
//                            completion(.failure(NSError(domain: "BookMarkService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Book story not found"])))
//                        case 409:
//                            completion(.failure(NSError(domain: "BookMarkService", code: 409, userInfo: [NSLocalizedDescriptionKey: "Bookmark already exists"])))
//                        default:
//                            completion(.failure(NSError(domain: "BookMarkService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Internal Server Error"])))
//                        }
//                    } else {
//                        completion(.failure(NSError(domain: "BookMarkService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
//                    }
//                }
//            }
//    }
//
//
//    
//    func getUserBookmarks(page: Int, pageSize: Int, completion: @escaping (Result<BookMarkListResponse, Error>) -> Void) {
//
//        var url = APIEndpoint.getUserBookmarksURL
//        
//        url += "?page=\(page)&pageSize=\(pageSize)"
//
//        guard let token = KeyChain.read(key: "JWTAccessToken") else {
//            completion(.failure(NSError(domain: "BookMarkService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
//            return
//        }
//
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//
//        AF.request(url, method: .get).responseDecodable(of: BookMarkListResponse.self) { response in
//            switch response.result {
//            case .success(let bookMarkListResponse):
//                completion(.success(bookMarkListResponse))
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    
//
//    func deleteBookMark(bookStoryId: String?, completion: @escaping (Result<DeleteResponse, Error>) -> Void) {
//        
//        guard let bookStoryId = bookStoryId, let url = URL(string: APIEndpoint.deleteBookmarkURL + "/\(bookStoryId)") else {
//            completion(.failure(NSError(domain: "BookMarkService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
//            return
//        }
//        
//        guard let token = KeyChain.read(key: "JWTAccessToken") else {
//            completion(.failure(NSError(domain: "BookMarkService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
//            return
//        }
//        
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//        
//        AF.request(url, method: .delete, headers: headers)
//            .responseDecodable(of: DeleteResponse.self) { response in
//                switch response.result {
//                case .success(let deleteResponse):
//                    completion(.success(deleteResponse))
//                case .failure:
//                    if let statusCode = response.response?.statusCode {
//                        switch statusCode {
//                        case 400:
//                            completion(.failure(NSError(domain: "BookMarkService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid book story ID"])))
//                        case 404:
//                            completion(.failure(NSError(domain: "BookMarkService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Bookmark not found"])))
//                        default:
//                            completion(.failure(NSError(domain: "BookMarkService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Internal Server Error"])))
//                        }
//                    } else {
//                        completion(.failure(NSError(domain: "BookMarkService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
//                    }
//                }
//            }
//    }
//
//}
