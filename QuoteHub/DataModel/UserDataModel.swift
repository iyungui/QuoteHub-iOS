//
//  UserDataModel.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/28.
//

import Foundation

struct SignInWithAppleResponse: Codable {
    let user: User
    let isFirstLogin: Bool
    let JWTAccessToken: String
    let JWTRefreshToken: String
}

struct User: Codable, Identifiable, Equatable {
    var id: String { _id }
    let _id: String
    let appleId: String?
    let nickname: String
    let profileImage: String
    let statusMessage: String?
    let monthlyReadingGoal: Int?
    var refreshToken: String?
    var followers: [String]?
    var following: [String]?
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

struct StoryCountResponse: Codable {
    let success: Bool
    let count: Int
}


// MARK: - 사용자 검색

struct SearchUserResponse: Codable {
    var success: Bool
    var users: [User]
    var message: String?
}
