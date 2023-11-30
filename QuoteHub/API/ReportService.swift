//
//  ReportService.swift
//  QuoteHub
//
//  Created by 이융의 on 11/25/23.
//

import Foundation
import Alamofire

class ReportService {

    func reportUser(targetId: String, reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = APIEndpoint.reportUserURL
        let parameters: Parameters = [
            "targetId": targetId,
            "reason": reason
        ]
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "ReportService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        // Alamofire를 사용한 POST 요청
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func reportBookStory(targetId: String, reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = APIEndpoint.reportStoryURL
        let parameters: Parameters = [
            "targetId": targetId,
            "reason": reason
        ]
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "ReportService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getReportUsers(completion: @escaping (Result<[ReportDataModel], Error>) -> Void) {
        let url = APIEndpoint.reportUserURL

        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "ReportService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        AF.request(url, method: .get, headers: headers).responseDecodable(of: [ReportDataModel].self) { response in
            switch response.result {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getReportStories(completion: @escaping (Result<[StoryReportDataModel], Error>) -> Void) {
        let url = APIEndpoint.reportStoryURL

        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "ReportService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        AF.request(url, method: .get, headers: headers).responseDecodable(of: [StoryReportDataModel].self) { response in
            switch response.result {
            case .success(let reports):
                completion(.success(reports))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

