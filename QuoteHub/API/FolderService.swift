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
    
    func createFolder(image: UIImage?, name: String, description: String?, isPublic: Bool, completion: @escaping (Result<FolderResponse, Error>) -> Void) {
        let url = APIEndpoint.createFolderURL
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            let error = NSError(domain: "FolderService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
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
        .responseDecodable(of: FolderResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 401:
                        UserAuthenticationManager().renewAccessToken { success in
                            if success {
                                self.createFolder(image: image, name: name, description: description, isPublic: isPublic, completion: completion)
                            } else {
                                let renewalError = NSError(domain: "FolderService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Token renewal failed"])
                                print("Error: \(renewalError.localizedDescription)")
                                completion(.failure(renewalError))
                            }
                        }
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
    func getAllFolders(page: Int, pageSize: Int, completion: @escaping (Result<FolderListResponse, Error>) -> Void) {
        let urlString = APIEndpoint.getAllFoldersURL + "?page=\(page)&pageSize=\(pageSize)"
                
        AF.request(urlString, method: .get).responseDecodable(of: FolderListResponse.self) { response in

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
    func getMyFolders(page: Int, pageSize: Int, completion: @escaping (Result<FolderListResponse, Error>) -> Void) {
        
        var urlString = APIEndpoint.getMyFoldersURL

        urlString += "?page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FolderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "FolderService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]


        AF.request(urlString, method: .get, headers: headers).responseDecodable(of: FolderListResponse.self) { response in
            switch response.result {
            case .success(let folderListResponse):
                completion(.success(folderListResponse))
            case .failure(let error):
                if response.response?.statusCode == 401 {
                    UserAuthenticationManager().renewAccessToken { success in
                        if success {
                            self.getMyFolders(page: page, pageSize: pageSize, completion: completion)
                        } else {
                            let renewalError = NSError(domain: "FolderService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Token renewal failed"])
                            completion(.failure(renewalError))
                        }
                    }
                }
            }
        }
    }
    
    // friend
    func getUserFolders(userId: String, page: Int, pageSize: Int, completion: @escaping (Result<FolderListResponse, Error>) -> Void) {
        
        var urlString = APIEndpoint.getUserFoldersURL

        urlString += "/\(userId)?page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FolderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .get).responseDecodable(of: FolderListResponse.self) { response in
            switch response.result {
            case .success(let folderListResponse):
                completion(.success(folderListResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - 폴더 수정
    
    func updateFolder(folderId: String, image: UIImage?, name: String, description: String?, isPublic: Bool, completion: @escaping (Result<FolderResponse, Error>) -> Void) {
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "BookStoryService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
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
        .responseDecodable(of: FolderResponse.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 401:
                        UserAuthenticationManager().renewAccessToken { success in
                            if success {
                                self.updateFolder(folderId: folderId, image: image, name: name, description: description, isPublic: isPublic, completion: completion)
                            } else {
                                let renewalError = NSError(domain: "BookStoryService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Token renewal failed"])
                                print("Error: \(renewalError.localizedDescription)")
                                completion(.failure(renewalError))
                            }
                        }
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
    
    func deleteFolder(folderId: String, completion: @escaping (Result<DeleteResponse, Error>) -> Void) {
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            let error = NSError(domain: "FolderService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        var urlString = APIEndpoint.deleteFolderURL

        urlString += "/\(folderId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FolderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: DeleteResponse.self) { response in
            switch response.result {
            case .success(let deleteResponse):
                completion(.success(deleteResponse))
            case .failure:
                if response.response?.statusCode == 401 {
                    UserAuthenticationManager().renewAccessToken { success in
                        if success {
                            self.deleteFolder(folderId: folderId, completion: completion)
                        } else {
                            completion(.failure(NSError(domain: "FolderService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Token renewal failed"])))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "FolderService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])))
                }
            }
        }
        
    }
}
