//
//  KeyChainTokenManager.swift
//  QuoteHub
//
//  Created by 이융의 on 10/23/23.
//

import Foundation
import KeychainAccess

final class KeyChainTokenManager {
    // MARK: - PROPERTIES
    
    private let keychain: Keychain
    
    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
    }
    
    init() {
        self.keychain = Keychain(service: "com.yungui.QuoteHub")
            .accessibility(.whenUnlockedThisDeviceOnly) // 디바이스 잠금 해제 시에만 접근
    }
    
    /// 로그인 응답 데이터를 keychain에 저장
    func saveTokenData(_ response: SignInWithAppleResponse) throws {
        // JWT 액세스 토큰 저장
        try keychain.set(response.accessToken, key: Keys.accessToken)
        
        // JWT 리프레시 토큰 저장
        try keychain.set(response.refreshToken, key: Keys.refreshToken)
    }
    
    /// 저장된 액세스 토큰을 반환
    func getAccessToken() -> String? {
        do {
            return try keychain.get(Keys.accessToken)
        } catch {
            return nil
        }
    }
    
    /// 리프레시 토큰을 반환
    func getRefreshToken() -> String? {
        do {
            return try keychain.get(Keys.refreshToken)
        } catch {
            return nil
        }
    }
    
    /// 액세스 토큰 업데이트 (토큰 리프레시 후 사용)
    func updateAccessToken(_ newToken: String) throws {
        try keychain.set(newToken, key: Keys.accessToken)
    }
    
    /// 액세스 토큰과 리프레시 토큰 둘 다 업데이트
    func updateBothTokens(newAccessToken: String, newRefreshToken: String) throws {
        try keychain.set(newAccessToken, key: Keys.accessToken)
        try keychain.set(newRefreshToken, key: Keys.refreshToken)
    }
    
    /// 저장된 토큰 데이터 모두 삭제 (로그아웃 시 사용)
    func clearAll() throws {
        try keychain.remove(Keys.accessToken)
        try keychain.remove(Keys.refreshToken)
    }
}
