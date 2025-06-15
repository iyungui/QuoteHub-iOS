//
//  BookService.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/01.
//

import Foundation
import SwiftUI
import Alamofire


class BookStoryService {
    
    // MARK: -  BookStory 생성
    
    func createBookStory(
        images: [UIImage]? = nil,
        bookId: String,
        quotes: [Quote],
        content: String? = nil,
        isPublic: Bool = false,
        keywords: [String]? = nil,
        themeIds: [String]? = nil,
        completion: @escaping (Result<BookStoryResponse, Error>) -> Void
    ) {
        
        guard let url = URL(string: APIEndpoint.createStoryURL) else {
            let error = NSError(domain: "BookStoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for creating book story"])
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        
        guard !quotes.isEmpty else {
            let error = NSError(domain: "BookStoryService", code: -7, userInfo: [NSLocalizedDescriptionKey : "At least one quote is required"])
            completion(.failure(error))
            return
        }
        
        var parameters: [String: Any] = [
            "bookId": bookId,
            "isPublic": isPublic,
        ]
        
        if let content = content, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parameters["content"] = content
        }
        
        if let keywords = keywords, !keywords.isEmpty {
            parameters["keywords"] = keywords
        }
        
        if let themeIds = themeIds, !themeIds.isEmpty {
            parameters["folderIds"] = themeIds
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            if let actualImages = images, !actualImages.isEmpty {
                for (index, actualImage) in actualImages.enumerated() {
                    if let resizedImage = actualImage.resizeWithWidth(width: 400),
                       let imageData = resizedImage.jpegData(compressionQuality: 0.9) {
                        multipartFormData.append(imageData, withName: "storyImage", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                    }
                }
            }
            
            for (key, value) in parameters {
                if let val = value as? String, !val.isEmpty {
                    multipartFormData.append(val.data(using: .utf8)!, withName: key)
                } else if let val = value as? Bool {
                    multipartFormData.append("\(val)".data(using: .utf8)!, withName: key)
                }
            }
            
            // quotes 배열을 JSON으로 인코딩해서 추가
            do {
                let quotesData = try JSONEncoder().encode(quotes)
                multipartFormData.append(quotesData, withName: "quotes")
            } catch {
                print("Error encoding quotes: \(error)")
            }
            
            // Append keywords and themeIds(folderIds) separately
            keywords?.forEach { keyword in
                multipartFormData.append(keyword.data(using: .utf8)!, withName: "keywords")
            }
            
            themeIds?.forEach { themeId in
                multipartFormData.append(themeId.data(using: .utf8)!, withName: "folderIds")
            }
            
        }, to: url, method: .post, headers: headers)
        .validate()
        .responseDecodable(of: BookStoryResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                    let generalError = NSError(domain: "BookStoryService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])
                    completion(.failure(generalError))
                
            }
        }
    }
    
    // MARK: - Get Book Story Count
 
    func getUserBookStoryCount(userId: String?, completion: @escaping (Result<CountResponse, Error>) -> Void) {
        var urlString = APIEndpoint.getUserStoryCount
        
        // Append the user ID to the URL if it's provided
        if let userId = userId, !userId.isEmpty {
            urlString += "/\(userId)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "BookStoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create headers only if a token exists
        var headers: HTTPHeaders?

        if let token = AuthService.shared.validAccessToken {
            headers = ["Authorization": "Bearer \(token)"]
        }
        
        AF.request(url, method: .get, headers: headers).responseDecodable(of: CountResponse.self) { response in
            switch response.result {
            case .success(let storyCountResponse):
                completion(.success(storyCountResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Public 북스토리 조회
    
    func fetchPublicBookStories(page: Int, pageSize: Int, completion: @escaping (Result<BookStoriesResponse, Error>) -> Void) {
        let urlString = APIEndpoint.getPublicStoryURL + "?page=\(page)&pageSize=\(pageSize)"
        
        AF.request(urlString, method: .get).responseDecodable(of: BookStoriesResponse.self) { response in
            switch response.result {
            case .success(let bookStoriesResponse):
                completion(.success(bookStoriesResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 내 서재 북스토리 조회
    
    func fetchMyBookStories(page: Int, pageSize: Int, completion: @escaping (Result<BookStoriesResponse, Error>) -> Void) {
        
        var urlString = APIEndpoint.getMyStoryURL

        urlString += "?page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "BookStoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]



        AF.request(urlString, method: .get, headers: headers).responseDecodable(of: BookStoriesResponse.self) { response in
            switch response.result {
            case .success(let bookStoriesResponse):
                completion(.success(bookStoriesResponse))
            case .failure(let error):
                    let generalError = NSError(domain: "BookStoryService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])
                    completion(.failure(generalError))
            }
        }
    }

    // MARK: -  특정 사용자 북스토리 조회
    
    func fetchFriendBookStories(friendId: String, page: Int, pageSize: Int, completion: @escaping (Result<BookStoriesResponse, Error>) -> Void) {
        
        var urlString = APIEndpoint.getFriendStoryURL

        urlString += "/\(friendId)?page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "BookStoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(urlString, method: .get).responseDecodable(of: BookStoriesResponse.self) { response in
            switch response.result {
            case .success(let bookStoriesResponse):
                completion(.success(bookStoriesResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 키워드 검색 (모두)
    
    func getAllPublicStoriesKeyword(keyword: String, page: Int, pageSize: Int, completion: @escaping (Result<BookStoriesResponse, Error>) -> Void) {
        let urlString = APIEndpoint.getAllPublicStoriesKeywordURL + "?keyword=\(keyword)&page=\(page)&pageSize=\(pageSize)"
        
        AF.request(urlString, method: .get).responseDecodable(of: BookStoriesResponse.self) { response in
            switch response.result {
            case .success(let bookStoriesResponse):
                completion(.success(bookStoriesResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 키워드 검색 (친구의 서재)
    
    func getAllFriendStoriesKeyword(friendId: String, keyword: String, page: Int, pageSize: Int, completion: @escaping (Result<BookStoriesResponse, Error>) -> Void) {
        let urlString = APIEndpoint.getFriendPublicStoriesKeywordURL + "?keyword=\(keyword)&page=\(page)&pageSize=\(pageSize)"
        
        AF.request(urlString, method: .get).responseDecodable(of: BookStoriesResponse.self) { response in
            switch response.result {
            case .success(let bookStoriesResponse):
                completion(.success(bookStoriesResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 키워드 검색 (내 서재)
    
    func getAllmyStoriesKeyword(keyword: String, page: Int, pageSize: Int, completion: @escaping (Result<BookStoriesResponse, Error>) -> Void) {
        let urlString = APIEndpoint.getMyStoriesKeywordURL + "?keyword=\(keyword)&page=\(page)&pageSize=\(pageSize)"
        
        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(urlString, method: .get, headers: headers).responseDecodable(of: BookStoriesResponse.self) { response in
            switch response.result {
            case .success(let bookStoriesResponse):
                completion(.success(bookStoriesResponse))
            case .failure(let error):
                    let generalError = NSError(domain: "BookStoryService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])
                    completion(.failure(generalError))
                
            }
        }
    }
    
    // MARK: -  BookStory 수정
    
    func updateBookStory(
        storyID: String,
        quotes: [Quote],
        images: [UIImage]? = nil,
        content: String? = nil,
        isPublic: Bool? = false,
        keywords: [String]? = nil,
        themeIds: [String]? = nil,
        completion: @escaping (Result<BookStoryResponse, Error>) -> Void
    ) {

        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        var urlString = APIEndpoint.updateStoryURL

        urlString += "/\(storyID)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "BookStoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        guard !quotes.isEmpty else {
            let error = NSError(domain: "BookStoryService", code: -7, userInfo: [NSLocalizedDescriptionKey: "At least one quote is required"])
            completion(.failure(error))
            return
        }
        
        // 각 quote의 유효성 검증
        for quote in quotes {
            guard !quote.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                let error = NSError(domain: "BookStoryService", code: -8, userInfo: [NSLocalizedDescriptionKey: "Quote text cannot be empty"])
                completion(.failure(error))
                return
            }
        }
        
        // 업데이트할 파라미터만 포함 (모든 필드 선택적)
        var parameters: [String: Any] = [:]
        
        if let content = content {
            parameters["content"] = content
        }
        
        if let isPublic = isPublic {
            parameters["isPublic"] = isPublic
        }
        
        if let keywords = keywords {
            parameters["keywords"] = keywords
        }
        
        if let themeIds = themeIds {
            parameters["folderIds"] = themeIds
        }

        
        AF.upload(multipartFormData: { (multipartFormData) in
            // 이미지 추가 (선택)
            if let actualImages = images, !actualImages.isEmpty {
                for (index, actualImage) in actualImages.enumerated() {
                    if let resizedImage = actualImage.resizeWithWidth(width: 400),
                       let imageData = resizedImage.jpegData(compressionQuality: 0.9) {
                        multipartFormData.append(imageData, withName: "storyImage", fileName: "image\(index).jpg", mimeType: "image/jpeg")
                    }
                }
            }

            // 일반 파라미터들 추가
            for (key, value) in parameters {
                if let val = value as? String {
                    multipartFormData.append(val.data(using: .utf8)!, withName: key)
                } else if let val = value as? Bool {
                    multipartFormData.append("\(val)".data(using: .utf8)!, withName: key)
                }
            }
            
            // quotes 배열이 제공된 경우에만 추가
            do {
                let quotesData = try JSONEncoder().encode(quotes)
                let quotesString = String(data: quotesData, encoding: .utf8) ?? "encoding failed"
                print("Quotes JSON being sent: \(quotesString)")
                multipartFormData.append(quotesData, withName: "quotes")
                print("Quotes successfully encoded and added to multipart data")
            } catch {
                print("Error encoding quotes: \(error)")
            }
            
            // keywords와 themeIds를 개별적으로 추가 (제공된 경우에만)
            keywords?.forEach { keyword in
                multipartFormData.append(keyword.data(using: .utf8)!, withName: "keywords")
            }
            
            themeIds?.forEach { themeId in
                multipartFormData.append(themeId.data(using: .utf8)!, withName: "folderIds")
            }
            
        }, to: url, method: .put, headers: headers)
        .validate()
        .responseDecodable(of: BookStoryResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 404:
                        let notFoundError = NSError(domain: "BookStoryService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Book story not found or access denied"])
                        completion(.failure(notFoundError))
                    default:
                        let generalError = NSError(domain: "BookStoryService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed with status code: \(statusCode)"])
                        completion(.failure(generalError))
                    }
                } else {
                    let unknownError = NSError(domain: "BookStoryService", code: -6, userInfo: [NSLocalizedDescriptionKey: "Unknown API Error"])
                    completion(.failure(unknownError))
                }
            }
        }
    }

    // MARK: - 특정 북스토리 하나 조회
    
    func fetchSpecificBookStory(storyId: String, completion: @escaping (Result<BookStoryResponse, Error>) -> Void) {
        var urlString = APIEndpoint.fetchSpecificStoryURL
        
        urlString += "/\(storyId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "BookStoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        AF.request(urlString, method: .get, headers: headers)
        .responseDecodable(of: BookStoryResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: -  BookStory 삭제 함수
    
    func deleteBookStory(storyID: String, completion: @escaping (Result<APIResponse<EmptyData>, Error>) -> Void) {

        guard let token = AuthService.shared.validAccessToken else {
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        var urlString = APIEndpoint.deleteStoryURL

        urlString += "/\(storyID)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "BookStoryService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: APIResponse<EmptyData>.self) { response in
            switch response.result {
            case .success(let deleteResponse):
                completion(.success(deleteResponse))
            case .failure:
                    completion(.failure(NSError(domain: "BookStoryService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])))
                
            }
        }
    }
    
    // MARK: - 폴더별 스토리 조회
    
    func getAllStoriesByFolder(folderId: String, page: Int, pageSize: Int, completion: @escaping (Result<BookStoriesResponse, Error>) -> Void) {
        let urlString = APIEndpoint.getAllPublicStoriesByFolderURL + "/\(folderId)?page=\(page)&pageSize=\(pageSize)"
        
        AF.request(urlString, method: .get).responseDecodable(of: BookStoriesResponse.self) { response in
            switch response.result {
            case .success(let bookStoriesResponse):
                completion(.success(bookStoriesResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getFriendStoriesByFolder(folderId: String, friendId: String, page: Int, pageSize: Int, completion: @escaping (Result<BookStoriesResponse, Error>) -> Void) {
        let urlString = APIEndpoint.getFriendPublicStoriesByFolderURL + "/\(friendId)/\(folderId)?page=\(page)&pageSize=\(pageSize)"
        
        AF.request(urlString, method: .get).responseDecodable(of: BookStoriesResponse.self) { response in
            switch response.result {
            case .success(let bookStoriesResponse):
                completion(.success(bookStoriesResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getMyStoriesByFolder(folderId: String, page: Int, pageSize: Int, completion: @escaping (Result<BookStoriesResponse, Error>) -> Void) {
        let urlString = APIEndpoint.getMyStoriesByFolderURL + "/\(folderId)?page=\(page)&pageSize=\(pageSize)"
        
        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        AF.request(urlString, method: .get, headers: headers).responseDecodable(of: BookStoriesResponse.self) { response in
            switch response.result {
            case .success(let bookStoriesResponse):
                completion(.success(bookStoriesResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
