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
