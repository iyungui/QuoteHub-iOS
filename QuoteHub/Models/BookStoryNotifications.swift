//
//  BookStoryNotifications.swift
//  QuoteHub
//
//  Created by 이융의 on 6/21/25.
//

import Foundation

// MARK: - BookStory 이벤트 정의
extension Notification.Name {
    /// 북스토리 생성 이벤트
    static let bookStoryCreated = Notification.Name("bookStoryCreated")
    
    /// 북스토리 수정 이벤트
    static let bookStoryUpdated = Notification.Name("bookStoryUpdated")
    
    /// 북스토리 삭제 이벤트
    static let bookStoryDeleted = Notification.Name("bookStoryDeleted")
}

// MARK: - UserInfo 키 정의
extension Notification {
    struct BookStoryKeys {
        /// BookStory 객체 키 (생성/수정시 사용)
        static let story = "story"
        
        /// 삭제된 북스토리 ID 키 (삭제시 사용)
        static let deletedStoryId = "deletedStoryId"
        
        /// 이전 북스토리 상태 키 (수정시 비교용)
        static let previousStory = "previousStory"
    }
}
