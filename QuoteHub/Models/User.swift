//
//  User.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/28.
//

import Foundation

/// 사용자 정보
struct User: Codable, Identifiable, Equatable {
    var id: String { _id }
    let _id: String
    let nickname: String
    let profileImage: String
    let statusMessage: String?
    let blockedUsers: [User]?
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
