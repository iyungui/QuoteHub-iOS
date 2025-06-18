//
//  AuthService.swift
//  QuoteHub
//
//  Created by 이융의 on 6/15/25.
//

import Foundation

protocol AuthServiceProtocol {
    func signInWithApple(authCode: String) async throws -> APIResponse<SignInWithAppleResponse>
    func validateAndRenewToken() async throws -> APIResponse<TokenValidationResponse>
    func revokeAccount() async throws -> APIResponse<RevokeAccountResponse>
}

final class AuthService: AuthServiceProtocol {
    
    // MARK: - Properties
    static let shared = AuthService()
    
    private let apiClient: APIClient
    private let tokenManager: KeyChainTokenManager

    // MARK: - Initialization
    private init(apiClient: APIClient = APIClient.shared,
                 tokenManager: KeyChainTokenManager = KeyChainTokenManager()) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
    }

    /// Apple 로그인
    /// - Parameter authCode: Apple에서 받은 인증 코드
    /// - Returns: 로그인 응답 데이터
    func signInWithApple(authCode: String) async throws -> APIResponse<SignInWithAppleResponse> {
        
        return try await apiClient.request(
            endpoint: AuthEndpoints.appleLogin,
            body: .dictionary(["code": authCode]),
            responseType: APIResponse<SignInWithAppleResponse>.self
        )
    }
    
    /// 토큰 검증 및 자동 갱신
    /// - Returns: 토큰 검증 결과 (Bool)
    func validateAndRenewToken() async throws -> APIResponse<TokenValidationResponse> {
        guard let accessToken = tokenManager.getAccessToken(),
              let refreshToken = tokenManager.getRefreshToken() else {
            throw NetworkError.unauthorized
        }
        
        let headers = [
            "Authorization": "Bearer \(accessToken)",
            "x-refresh-token": refreshToken
        ]
        
        return try await apiClient.request(
            endpoint: AuthEndpoints.validateAndRenewToken,
            body: .empty,
            responseType: APIResponse<TokenValidationResponse>.self,
            customHeaders: headers
        )
    }
    
    /// 닉네임 중복 체크
    /// - Parameters:
    ///   - nickname: 체크할 닉네임
    ///   - withAuth: 인증된 사용자로 체크할지 여부 (자신의 닉네임 체크 시 true)
    /// - Returns: 닉네임 사용 가능 여부
    func checkNickname(_ nickname: String, withAuth: Bool = false) async throws -> APIResponse<NicknameDuplicateResponse> {
        var headers: [String: String]? = nil
        
        // 인증이 필요한 경우 (로그인한 사용자가 자신의 닉네임 체크)
        if withAuth, let accessToken = tokenManager.getAccessToken() {
            headers = ["Authorization": "Bearer \(accessToken)"]
        }
        
        return try await apiClient.request(
            endpoint: AuthEndpoints.checkNickname(nickname: nickname),
            body: .empty,
            responseType: APIResponse<NicknameDuplicateResponse>.self,
            customHeaders: headers
        )
    }
    
    /// 닉네임 변경
    /// - Parameter nickname: 새로운 닉네임
    /// - Returns: 업데이트된 사용자 정보
    func changeNickname(_ nickname: String) async throws -> APIResponse<User> {
        let requestBody = ChangeNicknameRequest(nickname: nickname)
        
        return try await apiClient.request(
            endpoint: AuthEndpoints.changeNickname,
            body: .codable(requestBody),
            responseType: APIResponse<User>.self
        )
    }
    
    /// 계정 탈퇴
    func revokeAccount() async throws -> APIResponse<RevokeAccountResponse> {
        return try await apiClient.request(
            endpoint: AuthEndpoints.revokeAccount,
            body: .empty,
            responseType: APIResponse<RevokeAccountResponse>.self
        )
    }
    
    // MARK: - Token Storage Management
    
    /// 로그인 성공 후 토큰 저장
    func saveTokens(_ response: SignInWithAppleResponse) throws {
        try tokenManager.saveTokenData(response)
    }
    
    /// 새로운 액세스 토큰 저장
    func updateAccessToken(_ accessToken: String) throws {
        try tokenManager.updateAccessToken(accessToken)
    }
    
    func updateBothTokens(newAccessToken: String, newRefreshToken: String) throws {
        try tokenManager.updateBothTokens(newAccessToken: newAccessToken, newRefreshToken: newRefreshToken)
    }
    
    /// 현재 유효한 토큰이 있는지 확인
    var hasValidToken: Bool {
        return tokenManager.hasValidToken()
    }
    
    /// 현재 유효한 액세스 토큰 반환
    var validAccessToken: String? {
        return tokenManager.getAccessToken()
    }

    /// 저장된 모든 토큰 삭제 (로그아웃)
    func clearAllTokens() throws {
        try tokenManager.clearAll()
    }
}
