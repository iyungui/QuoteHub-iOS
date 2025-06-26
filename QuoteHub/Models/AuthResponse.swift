//
//  AuthResponse.swift
//  QuoteHub
//
//  Created by 이융의 on 6/26/25.
//

import Foundation

/// Apple 로그인 응답
struct SignInWithAppleResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
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

// 닉네임 생성 응답
struct GenerateNicknameResponse: Codable {
    let nickname: String
}

/// 닉네임 중복 체크 응답
struct NicknameDuplicateResponse: Codable {
    let available: Bool
}

/// 계정 탈퇴 응답
struct RevokeAccountResponse: Codable {
    let revoked: Bool
}

/// 닉네임 변경 요청 Body
struct ChangeNicknameRequest: Codable {
    let nickname: String
}
