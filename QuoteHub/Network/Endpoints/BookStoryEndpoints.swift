//
//  BookStoryEndpoints.swift
//  QuoteHub
//
//  Created by 이융의 on 6/17/25.
//

import Foundation

enum BookStoryEndpoints: EndpointProtocol {
    // 북스토리 생성, 수정, 삭제
    case createBookStory
    case updateBookStory(storyId: String)
    case deleteBookStory(storyId: String)
    
    // 북스토리 조회
    case fetchSpecificBookStory(storyId: String)
    case fetchPublicBookStories(page: Int, pageSize: Int)
    case fetchFriendBookStories(friendId: String, page: Int, pageSize: Int)
    case fetchMyBookStories(page: Int, pageSize: Int)
    
    // 키워드별 스토리 조회
    case fetchPublicBookStoriesByKeyword(keyword: String, page: Int, pageSize: Int)
    case fetchFriendBookStoriesByKeyword(friendId: String, keyword: String, page: Int, pageSize: Int)
    case fetchMyBookStoriesByKeyword(keyword: String, page: Int, pageSize: Int)
    
    // 테마별 스토리 조회
    case fetchPublicBookStoriesByTheme(themeId: String, page: Int, pageSize: Int)
    case fetchFriendBookStoriesByTheme(themeId: String, friendId: String, page: Int, pageSize: Int)
    case fetchMyBookStoriesByTheme(themeId: String, page: Int, pageSize: Int)
    
//    case deleteMultipleStory
    
    var path: String {
        switch self {
        case .createBookStory:
            return "/bookstories/createBookStory"
        case .updateBookStory(let storyId):
            return "/bookstories/update/\(storyId)"
        case .deleteBookStory(let storyId):
            return "/bookstories/delete/\(storyId)"
            
        case .fetchSpecificBookStory(let storyId):
            return "/bookstories/\(storyId)"

        case .fetchPublicBookStories(let page, let pageSize):
            return "/bookstories/public?page=\(page)&pageSize=\(pageSize)"
        case .fetchFriendBookStories(let friendId, let page, let pageSize):
            return "/bookstories/friend/\(friendId)?page=\(page)&pageSize=\(pageSize)"
        case .fetchMyBookStories(let page, let pageSize):
            return "/bookstories/my?page=\(page)&pageSize=\(pageSize)"
            
        case .fetchPublicBookStoriesByKeyword(let keyword, let page, let pageSize):
            return "/bookstories/public/search?keyword=\(keyword)&page=\(page)&pageSize=\(pageSize)"
        case .fetchFriendBookStoriesByKeyword(let friendId, let keyword, let page, let pageSize):
            return "/bookstories/friend/search/\(friendId)?keyword=\(keyword)&page=\(page)&pageSize=\(pageSize)"
        case .fetchMyBookStoriesByKeyword(let keyword, let page, let pageSize):
            return "/bookstories/my/search?keyword=\(keyword)&page=\(page)&pageSize=\(pageSize)"
            
        case .fetchPublicBookStoriesByTheme(let themeId, let page, let pageSize):
            return "/folder/public/\(themeId)?page=\(page)&pageSize=\(pageSize)"
        case .fetchFriendBookStoriesByTheme(let themeId, let friendId, let page, let pageSize):
            return "/folder/friend/\(friendId)/\(themeId)?page=\(page)&pageSize=\(pageSize)"
        case .fetchMyBookStoriesByTheme(let themeId, let page, let pageSize):
            return "/folder/my/\(themeId)?page=\(page)&pageSize=\(pageSize)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createBookStory:
            return .POST
        case .updateBookStory(let storyId):
            return .PUT
        case .deleteBookStory(let storyId):
            return .DELETE
        default:
            return .GET
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .createBookStory:
            return true
        case .updateBookStory(let storyId):
            return true
        case .deleteBookStory(let storyId):
            return true
        case .fetchSpecificBookStory(let storyId):
            return false
        case .fetchPublicBookStories(let page, let pageSize):
            return false
        case .fetchFriendBookStories(let friendId, let page, let pageSize):
            return false
        case .fetchMyBookStories(let page, let pageSize):
            return true
        case .fetchPublicBookStoriesByKeyword(let keyword, let page, let pageSize):
            return false
        case .fetchFriendBookStoriesByKeyword(let friendId, let keyword, let page, let pageSize):
            return false
        case .fetchMyBookStoriesByKeyword(let keyword, let page, let pageSize):
            return true
        case .fetchPublicBookStoriesByTheme(let themeId, let page, let pageSize):
            return false
        case .fetchFriendBookStoriesByTheme(let themeId, let friendId, let page, let pageSize):
            return false
        case .fetchMyBookStoriesByTheme(let themeId, let page, let pageSize):
            return true
        }
    }
}
