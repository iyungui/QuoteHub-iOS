//
//  UserEndpoints.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import Foundation

enum UserEndpoints: EndpointProtocol {
    case getProfile(userId: String?)
    case updateProfile
    case searchUser(nickname: String)
    case getUserStoryCount(userId: String?)
    
    var path: String {
        switch self {
        case .getProfile(let userId):
            return userId.map { "/profile/\($0)" } ?? "/profile"
        case .updateProfile:
            return "/profile"
        case .searchUser(let nickname):
            return "/user/search/\(nickname)"
        case .getUserStoryCount(let userId):
            return userId.map { "/bookstories/count/\($0)" } ?? "/bookstories/count"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateProfile: return .PUT
        default: return .GET
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .getProfile(let userId), .getUserStoryCount(let userId):
            return userId == nil  // userId가 nil일 때만 인증 필요
        default: return true
        }
    }
}
