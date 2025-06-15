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
        static let tokenExpiry = "token_expiry"
    }
    
    init() {
        self.keychain = Keychain(service: "com.yungui.QuoteHub")
            .accessibility(.whenUnlockedThisDeviceOnly) // 디바이스 잠금 해제 시에만 접근
    }
    
    /// 로그인 응답 데이터를 keychain에 저장
    func saveTokenData(_ response: SignInWithAppleResponse) throws {
        // 서버에서 주는 토큰 만료시간(1일)- TODO: - 보안 위해서 JWT 토큰 만료시간 좀 더 짧게 조정
        let expiryDate = Date().addingTimeInterval(24 * 60 * 60)
        
        // JWT 액세스 토큰 저장
        try keychain.set(response.accessToken, key: Keys.accessToken)
        
        // JWT 리프레시 토큰 저장
        try keychain.set(response.refreshToken, key: Keys.refreshToken)
        
        // 토큰 만료 시간을 timestamp로 변환해서 저장
        try keychain.set(String(expiryDate.timeIntervalSince1970), key: Keys.tokenExpiry)
    }
    
    /// 유효한 액세스 토큰을 반환
    func getAccessToken() -> String? {
        do {
            // keychain에 저장된 액세스토큰 가져오기
            guard let accessToken = try keychain.get(Keys.accessToken) else {
                // 토큰이 없으면 nil 반환
                return nil
            }
            
            // 토큰이 만료되었는지 확인
            if isAccessTokenExpired() {
                return nil  // 만료된 토큰은 nil 반환
            }
            
            return accessToken
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
    
    /// 5분 여유 두었을 때, 액세스 토큰이 만료되었는지 확인
    private func isAccessTokenExpired() -> Bool {
        do {
            // 로그인 시 저장했던 만료 시간 가져오기
            guard let expiryString = try keychain.get(Keys.tokenExpiry),
                  let expiryTimestamp = Double(expiryString) else {
                return true // 만료 시간이 없으면 만료된 것으로 처리
            }
            
            // timestamp를 Date로 변환
            let expiryDate = Date(timeIntervalSince1970: expiryTimestamp)
            
            // 현재 시간이 (만료시간 - 5분)보다 크거나 같으면 만료로 판단
            // 5분 여유두고 체크하는 이유는 네트워크 지연 가능성을 위해 미리 만료 체크
            return Date() >= expiryDate.addingTimeInterval(-300)
        } catch {
            return true
        }
    }
    
    /// 유효한 액세스 토큰이 있는지 확인
    func hasValidToken() -> Bool {
        // 액세스 토큰이 존재하고 만료되지 않았는지 확인
        return getAccessToken() != nil
    }
    
    /// 액세스 토큰 업데이트 (토큰 리프레시 후 사용)
    func updateAccessToken(_ newToken: String) throws {
        // 새로운 액세스 토큰도 1일 만료로 설정
        let newExpiryDate = Date().addingTimeInterval(24 * 60 * 60)
        
        // 액세스토큰, 만료시간 업데이트
        try keychain.set(newToken, key: Keys.accessToken)
        try keychain.set(String(newExpiryDate.timeIntervalSince1970), key: Keys.tokenExpiry)
    }
    
    func updateBothTokens(newAccessToken: String, newRefreshToken: String) throws {
        let newExpiryDate = Date().addingTimeInterval(24 * 60 * 60)
        
        try keychain.set(newAccessToken, key: Keys.accessToken)
        try keychain.set(newRefreshToken, key: Keys.refreshToken)
        try keychain.set(String(newExpiryDate.timeIntervalSince1970), key: Keys.tokenExpiry)
    }
    
    // 저장된 토큰 데이터 모두 삭제 (로그아웃 시 사용)
    func clearAll() throws {
        try keychain.remove(Keys.accessToken)
        try keychain.remove(Keys.refreshToken)
        try keychain.remove(Keys.tokenExpiry)
    }
}
