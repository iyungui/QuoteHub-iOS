//
//  FollowService.swift
//  QuoteHub
//
//  Created by 이융의 on 11/13/23.
//

import Foundation
import Alamofire

class FollowService {
    
    func followUser(userId: String, completion: @escaping(Result<FollowResponse, Error>) -> Void) {
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            let error = NSError(domain: "FolderService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        var urlString = APIEndpoint.followUserURL
        urlString += "/\(userId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FollowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .post, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: FollowResponse.self) { response in
                switch response.result {
                case .success(let followResponse):
                    completion(.success(followResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // check status
    func checkFollowStatus(userId: String, completion: @escaping (Result<checkFollowStatusResponse, Error>) -> Void) {

        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            let error = NSError(domain: "FolderService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let urlString = APIEndpoint.checkFollowStatusURL + "/\(userId)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FollowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        AF.request(url, method: .get, headers: headers).responseDecodable(of: checkFollowStatusResponse.self) { response in
            switch response.result {
            case .success(let followStatusResponse):
                completion(.success(followStatusResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 팔로워 목록 조회
    func getFollowers(userId: String, page: Int, pageSize: Int, completion: @escaping (Result<FollowListResponse, Error>) -> Void) {
        
        var urlString = APIEndpoint.getFollowersURL

        urlString += "/\(userId)?page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FollowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .get).responseDecodable(of: FollowListResponse.self) { response in
            switch response.result {
            case .success(let followListResponse):
                completion(.success(followListResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 팔로잉 목록 조회
    func getFollowing(userId: String, page: Int, pageSize: Int, completion: @escaping (Result<FollowListResponse, Error>) -> Void) {
        
        var urlString = APIEndpoint.getFollowingURL

        urlString += "/\(userId)?page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FollowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .get).responseDecodable(of: FollowListResponse.self) { response in
            switch response.result {
            case .success(let followListResponse):
                completion(.success(followListResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getFollowCounts(userId: String, completion: @escaping (Result<FollowCountResponse, Error>) -> Void) {
        var urlString = APIEndpoint.getFollowCountsURL + "/\(userId)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FollowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .get).responseDecodable(of: FollowCountResponse.self) { response in
            switch response.result {
            case .success(let followCountResponse):
                completion(.success(followCountResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 친구 차단 및 차단 해제
    func updateFollowStatus(userId: String, status: String, completion: @escaping(Result<FollowStatusResponse, Error>) -> Void) {
        var urlString = APIEndpoint.updateFollowStatusURL + "/\(userId)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FollowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "StoryCommentService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        let parameters: [String: Any] = [
            "status": status
        ]
        
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: FollowStatusResponse.self) { response in
            switch response.result {
            case .success(let followStatusResponse):
                completion(.success(followStatusResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func unfolllowUser(userId: String, completion: @escaping(Result<FollowResponse, Error>) -> Void) {
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            let error = NSError(domain: "FollowService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        var urlString = APIEndpoint.unfollowUserURL
        urlString += "/\(userId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FollowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .delete, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: FollowResponse.self) { response in
                switch response.result {
                case .success(let followResponse):
                    completion(.success(followResponse))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func getBlockedList(completion: @escaping (Result<[User], Error>) -> Void) {
        let url = APIEndpoint.blockedListURL
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            let error = NSError(domain: "FollowService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        AF.request(url, method: .get, headers: headers).responseDecodable(of: SearchUserResponse.self) { response in
            switch response.result {
            case .success(let response):
                completion(.success(response.data!))
            case .failure(let error):
                print("Error in getBlockedList: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
