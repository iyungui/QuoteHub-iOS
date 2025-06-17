//
//  User.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/28.
//

import Foundation


/// Apple 로그인 응답
struct SignInWithAppleResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

/// 사용자 정보
struct User: Codable, Identifiable, Equatable {
    var id: String { _id }
    let _id: String
    let nickname: String
    let profileImage: String
    let statusMessage: String?
    
    var followers: [String]?    //
    var following: [String]?    //
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}

/// 토큰 갱신 응답 (renewAccessToken)
struct RenewTokenResponse: Codable {
    let accessToken: String
}

/// 토큰 검증 응답 (validateToken)
struct TokenValidationResponse: Codable {
    let valid: Bool
    let accessToken: String?
    let refreshToken: String?
}

/// 닉네임 중복 체크 응답
struct NicknameDuplicateResponse: Codable {
    let available: Bool
}

/// 계정 탈퇴 응답
struct RevokeAccountResponse: Codable {
    let revoked: Bool
}

/// Apple 로그인 요청 Body
struct AppleLoginRequest: Codable {
    let code: String
}

/// 닉네임 변경 요청 Body
struct ChangeNicknameRequest: Codable {
    let nickname: String
}
