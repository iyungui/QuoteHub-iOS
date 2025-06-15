//
//  FolderService.swift
//  QuoteHub
//
//  Created by 이융의 on 11/10/23.
//

import Foundation
import Alamofire
import SwiftUI

class FolderService {
    
    func createFolder(image: UIImage?, name: String, description: String?, isPublic: Bool, completion: @escaping (Result<ThemeResponse, Error>) -> Void) {
        let url = APIEndpoint.createFolderURL
        
        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        
        let parameters: [String: Any] = [
            "name": name,
            "description": description ?? "",
            "isPublic": isPublic
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            if let actualImage = image,
               let resizedImage = actualImage.resizeWithWidth(width: 400),
               let imageData = resizedImage.jpegData(compressionQuality: 0.9) {
                multipartFormData.append(imageData, withName: "folderImage", fileName: "image.jpg", mimeType: "image/jpeg")
            }
    
            for (key, value) in parameters {
                if let val = value as? String {
                    multipartFormData.append(val.data(using: .utf8)!, withName: key)
                } else if let val = value as? Bool {
                    multipartFormData.append(val ? "true".data(using: .utf8)! : "false".data(using: .utf8)!, withName: key)
                }
            }
            
        }, to: url, method: .post, headers: headers)
        .responseDecodable(of: ThemeResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 409:
                        let duplicateError = NSError(domain: "FolderService", code: 409, userInfo: [NSLocalizedDescriptionKey: "Folder already exists"])
                        completion(.failure(duplicateError))
                    default:
                        let generalError = NSError(domain: "FolderService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])
                        completion(.failure(generalError))
                    }
                }
            }
        }
    }
    
    // MARK: - 폴더 목록 조회
    
    // public
    func getAllFolders(page: Int, pageSize: Int, completion: @escaping (Result<ThemesListResponse, Error>) -> Void) {
        let urlString = APIEndpoint.getAllFoldersURL + "?page=\(page)&pageSize=\(pageSize)"
                
        AF.request(urlString, method: .get).responseDecodable(of: ThemesListResponse.self) { response in

            switch response.result {
            case .success(let folderListResponse):
                completion(.success(folderListResponse))
            case .failure(let error):
                print("Error fetching folder list: \(error)")
                completion(.failure(error))
            }
        }
    }

    
    // my
    func getMyFolders(page: Int, pageSize: Int, completion: @escaping (Result<ThemesListResponse, Error>) -> Void) {
        
        var urlString = APIEndpoint.getMyFoldersURL

        urlString += "?page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FolderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]


        AF.request(urlString, method: .get, headers: headers).responseDecodable(of: ThemesListResponse.self) { response in
            switch response.result {
            case .success(let folderListResponse):
                completion(.success(folderListResponse))
            case .failure(let error):
                let renewalError = NSError(domain: "FolderService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Token renewal failed"])
                completion(.failure(renewalError))
            }
        }
    }
    
    // friend
    func getUserFolders(userId: String, page: Int, pageSize: Int, completion: @escaping (Result<ThemesListResponse, Error>) -> Void) {
        
        var urlString = APIEndpoint.getUserFoldersURL

        urlString += "/\(userId)?page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FolderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .get).responseDecodable(of: ThemesListResponse.self) { response in
            switch response.result {
            case .success(let folderListResponse):
                completion(.success(folderListResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - 폴더 수정
    
    func updateFolder(folderId: String, image: UIImage?, name: String, description: String?, isPublic: Bool, completion: @escaping (Result<ThemeResponse, Error>) -> Void) {
        
        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        var urlString = APIEndpoint.updateFolderURL

        urlString += "/\(folderId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FolderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let parameters: [String: Any] = [
            "name": name,
            "description": description ?? "",
            "isPublic": isPublic
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            if let actualImage = image,
               let resizedImage = actualImage.resizeWithWidth(width: 400),
               let imageData = resizedImage.jpegData(compressionQuality: 0.9) {
                multipartFormData.append(imageData, withName: "folderImage", fileName: "image.jpg", mimeType: "image/jpeg")
            }

            for (key, value) in parameters {
                if let val = value as? String, !val.isEmpty {
                    multipartFormData.append(val.data(using: .utf8)!, withName: key)
                } else if let val = value as? Bool {
                    multipartFormData.append("\(val)".data(using: .utf8)!, withName: key)
                }
            }
        }, to: url, method: .put, headers: headers)
        .validate()
        .responseDecodable(of: ThemeResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                        
                    case 404:
                        let notFoundError = NSError(domain: "FolderService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Folder not found or access denied"])
                        completion(.failure(notFoundError))
                    default:
                        let generalError = NSError(domain: "FolderService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed with status code: \(statusCode)"])
                        completion(.failure(generalError))
                    }
                } else {
                    let unknownError = NSError(domain: "FolderService", code: -6, userInfo: [NSLocalizedDescriptionKey: "Unknown API Error"])
                    completion(.failure(unknownError))
                }
            }
        }
    }

    
    // MARK: - 폴더 삭제
    
    func deleteFolder(folderId: String, completion: @escaping (Result<APIResponse<EmptyData>, Error>) -> Void) {
        
        guard let token = AuthService.shared.validAccessToken else {
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        var urlString = APIEndpoint.deleteFolderURL

        urlString += "/\(folderId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FolderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: APIResponse<EmptyData>.self) { response in
            switch response.result {
            case .success(let deleteResponse):
                completion(.success(deleteResponse))
            case .failure:
                    completion(.failure(NSError(domain: "FolderService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])))
                
            }
        }
        
    }
}
