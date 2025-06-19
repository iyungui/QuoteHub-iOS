//
//  APIEndpoint.swift
//  QuoteHub
//
//  Created by 이융의 on 10/6/23.
//

import Foundation

struct APIEndpoint {
    
    static private let baseURL = "https://port-0-quotehub-server-m015aiy374b6cd11.sel4.cloudtype.app/"
    
    
    // MARK: - BOOKSTORY COMMENT
    
    static let addCommentToStoryURL = baseURL + "bookstoriesComments"
    static let getCommentForStoryURL = baseURL + "bookstoriesComments"    // + /bookStoryId
    static let getCommentCountForStoryURL = baseURL + "bookstoriesComments/count"   // + /bookStoryId
    static let deleteCommentStoryURL = baseURL + "bookstoriesComments"    // + /commentId
    
    // MARK: - FOLLOW
    
    static let followUserURL = baseURL + "follow"   // + /userId
    static let getFollowersURL = baseURL + "follow/followers" // + /userId
    static let getFollowingURL = baseURL + "follow/following"   // + /userId
    static let getFollowCountsURL = baseURL + "follow/counts"   // + /userId
    static let unfollowUserURL = baseURL + "follow/unfollow"  // + /userId

    static let checkFollowStatusURL = baseURL + "follow/check"
    
    // 사용자 검색 api
    static let searchUserURL = baseURL + "follow/user/search"  // + /nickname (json)
    
    // 차단 목록 api
    static let updateFollowStatusURL = baseURL + "follow/update"  // + /userId
    static let blockedListURL = baseURL + "follow/blockedList"

    
    // MARK: - BOOKMARK
    
    static let createBookmarkURL = baseURL + "bookmarks"    // + /bookstoryId
    static let getUserBookmarksURL = baseURL + "bookmarks"
    static let deleteBookmarkURL = baseURL + "bookmarks"    // + /bookstoryId
    
    // MARK: - 신고 기능
    
    static let reportUserURL = baseURL + "reports/user"
    static let reportStoryURL = baseURL + "reports/bookstory"
    static let getReportListURL = baseURL + "reports/admin/reportList"
}
