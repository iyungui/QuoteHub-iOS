//
//  FollowService.swift
//  QuoteHub
//
//  Created by 이융의 on 11/13/23.
//

import Foundation
import Alamofire

class FollowService {
    // check status
    func checkFollowStatus(userId: String, completion: @escaping (Result<CheckFollowStatus, Error>) -> Void) {

        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let urlString = APIEndpoint.checkFollowStatusURL + "/\(userId)"

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FollowService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        AF.request(url, method: .get, headers: headers).responseDecodable(of: CheckFollowStatusResponse.self) { response in
            switch response.result {
            case .success(let followStatusResponse):
                completion(.success(followStatusResponse.data!))
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
        guard let token = AuthService.shared.validAccessToken else {
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
    
    func getBlockedList(completion: @escaping (Result<[User], Error>) -> Void) {
        let url = APIEndpoint.blockedListURL
        guard let token = AuthService.shared.validAccessToken else {
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
