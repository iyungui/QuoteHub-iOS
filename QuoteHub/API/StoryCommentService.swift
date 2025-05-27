//
//  StoryCommentService.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import Foundation
import Alamofire

class StoryCommentService {
    
    // MARK: - add BookStory Comment

    func addCommentToStory(bookStoryId: String, content: String, parentCommentId: String?, completion: @escaping (Result<BookStoryCommentResponse, Error>) -> Void) {
        guard let url = URL(string: APIEndpoint.addCommentToStoryURL) else {
            completion(.failure(NSError(domain: "StoryCommentService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "StoryCommentService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }
        
        let parameters: [String: Any] = [
            "bookStoryId": bookStoryId,
            "content": content,
            "parentCommentId": parentCommentId ?? NSNull()
        ]
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: BookStoryCommentResponse.self) { response in
            switch response.result {
            case .success(let postCommentResponse):
                completion(.success(postCommentResponse))
            case .failure:
                if response.response?.statusCode == 401 {
                    UserAuthenticationManager().renewAccessToken { success in
                        if success {
                            self.addCommentToStory(bookStoryId: bookStoryId, content: content, parentCommentId: parentCommentId, completion: completion)
                        } else {
                            completion(.failure(NSError(domain: "StoryCommentService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Token renewal failed"])))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "StoryCommentService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])))
                }
            }
        }
    }


    // MARK: - get BookStory Comment

    func getCommentforStory(bookStoryId: String, page: Int, pageSize: Int, completion: @escaping (Result<BookStoryCommentsResponse, Error>) -> Void) {
        
        var urlString = APIEndpoint.getCommentForStoryURL

        urlString += "/\(bookStoryId)?page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "StoryCommentService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .get).responseDecodable(of: BookStoryCommentsResponse.self) { response in
            switch response.result {
            case .success(let bookStoryCommentResponse):
                completion(.success(bookStoryCommentResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - get Comments Count
    
    func getCommentCountForStory(bookStoryId: String, completion: @escaping (Result<CommentCountResponse, Error>) -> Void) {
        var urlString = APIEndpoint.getCommentCountForStoryURL + "/\(bookStoryId)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "StoryCommentService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .get).responseDecodable(of: CommentCountResponse.self) { response in
            switch response.result {
            case .success(let commentCountResponse):
                completion(.success(commentCountResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - delete BookStory Comment

    func deleteCommentStory(commentId: String, completion: @escaping (Result<APIResponse<EmptyData>, Error>) -> Void) {
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "StoryCommentService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        var urlString = APIEndpoint.deleteCommentStoryURL
        urlString += "/\(commentId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "StoryCommentService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: APIResponse<EmptyData>.self) { response in
            switch response.result {
            case .success(let deleteResponse):
                completion(.success(deleteResponse))
            case .failure:
                if response.response?.statusCode == 401 {
                    UserAuthenticationManager().renewAccessToken { success in
                        if success {
                            self.deleteCommentStory(commentId: commentId, completion: completion)
                        } else {
                            completion(.failure(NSError(domain: "StoryCommentService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Token renewal failed"])))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "StoryCommentService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])))
                }
            }
        }
    }
}
