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
    case getAllThemes
    case getUserThemes(userId: String)
    case getMyThemes
    
    var path: String {
        switch self {
        case .createTheme:
            return "/folder/create"
        case .updateTheme(let themeId):
            return "/folder/update/\(themeId)"
        case .deleteTheme(let themeId):
            return "/folder/delete/\(themeId)"
            
        case .getAllThemes:
            return "/folder/all"
        case .getUserThemes(let userId):
            return "/folder/user/\(userId)"
        case .getMyThemes:
            return "/folder/myfolder"
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
        case .getAllThemes, .getUserThemes:
            return false
        default:
            return true
        }
    }
}
