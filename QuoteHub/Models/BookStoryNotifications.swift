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

// MARK: - 편의 메서드 (선택사항 - 기본 post 메서드 사용 권장)
extension NotificationCenter {
    
    /// 북스토리 생성 이벤트 발송
    func postBookStoryCreated(_ story: BookStory) {
        post(name: .bookStoryCreated, object: nil, userInfo: [
            Notification.BookStoryKeys.story: story
        ])
    }
    
    /// 북스토리 수정 이벤트 발송
    func postBookStoryUpdated(_ story: BookStory, previousStory: BookStory? = nil) {
        var userInfo: [String: Any] = [
            Notification.BookStoryKeys.story: story
        ]
        
        if let previousStory = previousStory {
            userInfo[Notification.BookStoryKeys.previousStory] = previousStory
        }
        
        post(name: .bookStoryUpdated, object: nil, userInfo: userInfo)
    }
    
    /// 북스토리 삭제 이벤트 발송
    func postBookStoryDeleted(storyId: String) {
        post(name: .bookStoryDeleted, object: nil, userInfo: [
            Notification.BookStoryKeys.deletedStoryId: storyId
        ])
    }
}

// MARK: - 이벤트 수신 헬퍼 (선택사항 - 직접 userInfo 접근 권장)
extension Notification {
    
    /// 생성/수정된 북스토리 추출
    var bookStory: BookStory? {
        return userInfo?[BookStoryKeys.story] as? BookStory
    }
    
    /// 이전 북스토리 상태 추출 (수정시)
    var previousBookStory: BookStory? {
        return userInfo?[BookStoryKeys.previousStory] as? BookStory
    }
    
    /// 삭제된 북스토리 ID 추출
    var deletedStoryId: String? {
        return userInfo?[BookStoryKeys.deletedStoryId] as? String
    }
}
