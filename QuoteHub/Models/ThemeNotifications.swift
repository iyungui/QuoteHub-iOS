//
//  ThemeNotifications.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import Foundation

// MARK: - Theme 이벤트 정의
extension Notification.Name {
    /// 테마 생성 이벤트
    static let themeCreated = Notification.Name("themeCreated")
    
    /// 테마 수정 이벤트
    static let themeUpdated = Notification.Name("themeUpdated")
    
    /// 테마 삭제 이벤트
    static let themeDeleted = Notification.Name("themeDeleted")
}

// MARK: - UserInfo 키 정의
extension Notification {
    struct ThemeKeys {
        /// Theme 객체 키 (생성/수정시 사용)
        static let theme = "theme"
        
        /// 삭제된 테마 ID 키 (삭제시 사용)
        static let deletedThemeId = "deletedThemeId"
        
        /// 이전 테마 상태 키 (수정시 비교용)
        static let previousTheme = "previousTheme"
    }
}

// MARK: - 편의 메서드 (선택사항 - 기본 post 메서드 사용 권장)
extension NotificationCenter {
    
    /// 테마 생성 이벤트 발송
    func postThemeCreated(_ theme: Theme) {
        post(name: .themeCreated, object: nil, userInfo: [
            Notification.ThemeKeys.theme: theme
        ])
    }
    
    /// 테마 수정 이벤트 발송
    func postThemeUpdated(_ theme: Theme, previousTheme: Theme? = nil) {
        var userInfo: [String: Any] = [
            Notification.ThemeKeys.theme: theme
        ]
        
        if let previousTheme = previousTheme {
            userInfo[Notification.ThemeKeys.previousTheme] = previousTheme
        }
        
        post(name: .themeUpdated, object: nil, userInfo: userInfo)
    }
    
    /// 테마 삭제 이벤트 발송
    func postThemeDeleted(themeId: String) {
        post(name: .themeDeleted, object: nil, userInfo: [
            Notification.ThemeKeys.deletedThemeId: themeId
        ])
    }
}

// MARK: - 이벤트 수신 헬퍼 (선택사항 - 직접 userInfo 접근 권장)
extension Notification {
    
    /// 생성/수정된 테마 추출
    var theme: Theme? {
        return userInfo?[ThemeKeys.theme] as? Theme
    }
    
    /// 이전 테마 상태 추출 (수정시)
    var previousTheme: Theme? {
        return userInfo?[ThemeKeys.previousTheme] as? Theme
    }
    
    /// 삭제된 테마 ID 추출
    var deletedThemeId: String? {
        return userInfo?[ThemeKeys.deletedThemeId] as? String
    }
}
