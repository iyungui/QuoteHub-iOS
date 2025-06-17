//
//  UserService.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/28.
//

import SwiftUI

protocol UserServiceProtocol {
    func getProfile(userId: String?) async throws -> APIResponse<User>
    func updateProfile(nickname: String, profileImage: UIImage?, statusMessage: String) async throws -> APIResponse<User>
    func searchUser(nickname: String) async throws -> APIResponse<[User]>
    
    func getUserBookStoryCount(userId: String?) async throws -> APIResponse<Int>
}

final class UserService: UserServiceProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    func getProfile(userId: String?) async throws -> APIResponse<User> {
        return try await apiClient.request(
            endpoint: UserEndpoints.getProfile(userId: userId),
            body: EmptyData(),
            responseType: APIResponse<User>.self
        )
    }
    
    func updateProfile(nickname: String, profileImage: UIImage?, statusMessage: String) async throws -> APIResponse<User> {
        
        if let profileImage = profileImage {
            // 이미지가 있는 경우 multipart 요청
            return try await apiClient.requestWithMultipart(
                endpoint: UserEndpoints.updateProfile,
                textFields: [
                    "nickname": nickname,
                    "statusMessage": statusMessage
                ],
                imageFields: [
                    "profileImage": profileImage
                ],
                responseType: APIResponse<User>.self
            )
        } else {
            // 이미지가 없는 경우
            let requestBody: [String: String] = [
                "nickname": nickname,
                "statusMessage": statusMessage
            ]
            
            return try await apiClient.request(
                endpoint: UserEndpoints.updateProfile,
                body: requestBody,
                responseType: APIResponse<User>.self
            )
        }
    }
    
    func searchUser(nickname: String) async throws -> APIResponse<[User]> {
        
        return try await apiClient.request(
            endpoint: UserEndpoints.searchUser(nickname: nickname),
            body: EmptyData(),
            responseType: APIResponse<[User]>.self
        )
    }
    
    func getUserBookStoryCount(userId: String?) async throws -> APIResponse<Int> {
        
        return try await apiClient.request(
            endpoint: UserEndpoints.getUserStoryCount(userId: userId),
            body: EmptyData(),
            responseType: APIResponse<Int>.self
        )
    }
}
