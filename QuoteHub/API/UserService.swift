//
//  UserService.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/28.
//

import Foundation
import Alamofire
import SwiftUI
import Alamofire

class UserService {
    
    // MARK: - GET LIST USERS
    
    func getListUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        
        let url = APIEndpoint.getListUsersURL
        
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, encoding: JSONEncoding.default)
            .responseDecodable(of: [User].self) { response in
                switch response.result {
                case .success(let users):
                    completion(.success(users))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: -  프로필 가져오기
    
    func getProfile(userId: String?, completion: @escaping (Result<User, Error>) -> Void) {
        
        var headers: HTTPHeaders?
        if let token = KeyChain.read(key: "JWTAccessToken") {
            headers = ["Authorization": "Bearer \(token)"]
        }

        var urlString = APIEndpoint.getProfileURL
        
        if let userId = userId {
            urlString += "/\(userId)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
            .responseDecodable(of: UserResponse.self) { response in // User.self -> UserResponse.self로 변경
                switch response.result {
                case .success(let userResponse):
                    if userResponse.success {
                        completion(.success(userResponse.data)) // userResponse.data를 반환
                    } else {
                        completion(.failure(NSError(domain: "UserService", code: -5, userInfo: [NSLocalizedDescriptionKey: userResponse.error ?? "Unknown error"])))
                    }
                case .failure:
                    if response.response?.statusCode == 401 {
                        UserAuthenticationManager().renewAccessToken { success in
                            if success {
                                print("retry")
                                self.getProfile(userId: userId, completion: completion)
                            } else {
                                completion(.failure(NSError(domain: "UserService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Token renewal failed"])))
                            }
                        }
                    } else {
                        // 디버깅을 위한 추가 정보
                        let statusCode = response.response?.statusCode ?? -1
                        let errorDescription = response.error?.localizedDescription ?? "Unknown error"
                        print("Profile API Error - Status Code: \(statusCode), Error: \(errorDescription)")
                        
                        completion(.failure(NSError(domain: "UserService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed with status \(statusCode): \(errorDescription)"])))
                    }
                }
            }
    }

    func updateProfile(nickname: String, profileImage: UIImage?, statusMessage: String, monthlyReadingGoal: Int, completion: @escaping (Result<User, Error>) -> Void) {

        guard let url = URL(string: APIEndpoint.updateProfileURL) else {
            completion(.failure(NSError(domain: "UserService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "UserService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let parameters: [String: Any] = [
            "nickname": nickname,
            "statusMessage": statusMessage,
            "monthlyReadingGoal": monthlyReadingGoal
        ]
        
        AF.upload(multipartFormData: { (multipartFormData) in
            if let actualImage = profileImage,
               let resizedImage = actualImage.resizeWithWidth(width: 400),
               let imageData = resizedImage.jpegData(compressionQuality: 0.9) {
                multipartFormData.append(imageData, withName: "profileImage", fileName: "image.jpg", mimeType: "image/jpeg")
            }
            
            for (key, value) in parameters {
                if let val = value as? String {
                    multipartFormData.append(val.data(using: .utf8)!, withName: key)
                } else if let val = value as? Int {
                    multipartFormData.append("\(val)".data(using: .utf8)!, withName: key)
                }
            }
        }, to: url, method: .put, headers: headers).responseDecodable(of: UserResponse.self) { response in // User.self -> UserResponse.self로 변경
            switch response.result {
            case .success(let userResponse):
                if userResponse.success {
                    completion(.success(userResponse.data)) // userResponse.data를 반환
                } else {
                    completion(.failure(NSError(domain: "UserService", code: -5, userInfo: [NSLocalizedDescriptionKey: userResponse.error ?? "Update failed"])))
                }
            case .failure:
                if let statusCode = response.response?.statusCode {
                    switch statusCode {
                    case 400:  // Bad Request, 백엔드에서 정의한 오류 코드
                        if let data = response.data,
                           let backendError = try? JSONDecoder().decode(BackendErrorResponse.self, from: data) {
                            completion(.failure(NSError(domain: "UserService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: backendError.error])))
                        } else {
                            completion(.failure(NSError(domain: "UserService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "An error occurred"])))
                        }
                    case 401:   // Unauthorized
                        UserAuthenticationManager().renewAccessToken { success in
                            if success {
                                self.updateProfile(nickname: nickname, profileImage: profileImage, statusMessage: statusMessage, monthlyReadingGoal: monthlyReadingGoal, completion: completion)    // retry
                            } else {
                                completion(.failure(NSError(domain: "UserService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Token renewal failed"])))
                            }
                        }
                    default:
                        completion(.failure(NSError(domain: "UserService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "API Request Failed with status \(statusCode)"])))
                    }
                } else {
                    completion(.failure(NSError(domain: "UserService", code: -4, userInfo: [NSLocalizedDescriptionKey: "API Request Failed"])))
                }
            }
        }
    }
    
    func searchUser(nickname: String, completion: @escaping (Result<SearchUserResponse, Error>) -> Void) {
        
        let url = APIEndpoint.searchUserURL
        
        let parameters = ["nickname": nickname]
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "UserService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        AF.request(url, method: .get, parameters: parameters, headers: headers).responseDecodable(of: SearchUserResponse.self) { response in
            switch response.result {
            case .success(let searchUserResponse):
                if searchUserResponse.success {
                    completion(.success(searchUserResponse))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "API error"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
}

// MARK: - Image Resize

extension UIImage {
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let aspectSize = CGSize(width: width, height: aspectRatio * width)
        UIGraphicsBeginImageContext(aspectSize)
        draw(in: CGRect(origin: .zero, size: aspectSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    var aspectRatio: CGFloat {
        return size.height / size.width
    }
}
