//
//  ThemeEndpoints.swift
//  QuoteHub
//
//  Created by 이융의 on 6/19/25.
//

import Foundation

enum ThemeEndpoints: EndpointProtocol {
    // 테마(폴더) 생성, 수정, 삭제
    case createTheme
    case updateTheme(themeId: String)
    case deleteTheme(themeId: String)
    
    // 테마(폴더) 목록 조회
    case getAllThemes(page: Int, pageSize: Int)
    case getUserThemes(userId: String, page: Int, pageSize: Int)
    case getMyThemes(page: Int, pageSize: Int)
    
    // 테마별 스토리 조회
    case getPublicStoriesByTheme(themeId: String)
    case getFriendStoriesByTheme(friendId: String, themeId: String)
    case getMyStoriesByTheme(themeId: String)
    
    // 단일 테마 조회
    case fetchSpecificTheme(themeId: String)

    var path: String {
        switch self {
        case .createTheme:
            return "/folder/create"
        case .updateTheme(let themeId):
            return "/folder/update/\(themeId)"
        case .deleteTheme(let themeId):
            return "/folder/delete/\(themeId)"
            
        case .getAllThemes(let page, let pageSize):
            return "/folder/all?page=\(page)&pageSize=\(pageSize)"
        case .getUserThemes(let userId, let page, let pageSize):
            return "/folder/user/\(userId)?page=\(page)&pageSize=\(pageSize)"
        case .getMyThemes(let page, let pageSize):
            return "/folder/myfolder?page=\(page)&pageSize=\(pageSize)"
            
        case .getPublicStoriesByTheme(let themeId):
            return "/folder/public/\(themeId)"
        case .getFriendStoriesByTheme(let friendId, let themeId):
            return "/folder/friend/\(friendId)/\(themeId)"
        case .getMyStoriesByTheme(let themeId):
            return "/folder/my/\(themeId)"
        case .fetchSpecificTheme(let themeId):
            return "/folder/\(themeId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createTheme:
            return .POST
        case .updateTheme:
            return .PUT
        case .deleteTheme:
            return .DELETE
        default:
            return .GET
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .getAllThemes, .getPublicStoriesByTheme, .getFriendStoriesByTheme, .fetchSpecificTheme:
            return false
        default:
            return true
        }
    }
}
