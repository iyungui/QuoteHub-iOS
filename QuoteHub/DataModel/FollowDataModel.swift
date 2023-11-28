//
//  FollowDataModel.swift
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


// 팔로우, 팔로우 해제
struct FollowResponse: Codable {
    var success: Bool
    var data: User
    let error: String?
}

// 팔로워, 팔로잉 목록 조회
struct FollowListResponse: Codable {
    var success: Bool
    var data: [User]
    var currentPage: Int
    var totalPages: Int
    var pageSize: Int
    var totalItems: Int
    let error: String?
}

struct FollowCountResponse: Codable {
    var success: Bool
    var followersCount: Int
    var followingCount: Int
}

// 팔로우 차단 및 차단 해제
struct FollowStatusResponse: Codable {
    var success: Bool?
    var data: Follow?
    var message: String?
    var error: String?
}

struct checkFollowStatusResponse: Codable {
    var success: Bool
    var isFollowing: Bool
    var isBlocked: Bool
}


// 차단 목록 API
struct BlockedUsersResponse: Codable {
    let success: Bool
    var blockedList: [User]
}
