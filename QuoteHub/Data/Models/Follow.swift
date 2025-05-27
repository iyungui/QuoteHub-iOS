//
//  Follow.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import Foundation

struct Follow: Codable, Identifiable {
    var id: String { _id }
    let _id: String
    
    let follower: String
    let following: String
    let status: Status
    
    let createdAt: String
    let updatedAt: String
    
    var createdAtDate: String {
        return String(createdAt.prefix(10))
    }
    
    var updatedAtDate: String {
        return String(updatedAt.prefix(10))
    }
    
    enum Status: String, Codable {
        case following = "FOLLOWING"
        case blocked = "BLOCKED"
    }
}

struct FollowCount: Codable {
    var followersCount: Int
    var followingCount: Int
}

struct CheckFollowStatus: Codable {
    var isFollowing: Bool
    var isBlocked: Bool
}
