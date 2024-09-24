//
//  APIEndpoint.swift
//  QuoteHub
//
//  Created by 이융의 on 10/6/23.
//

import Foundation

struct APIEndpoint {
    
    static private let baseURL = "https://port-0-quotehub-server-m015aiy374b6cd11.sel4.cloudtype.app/"
    
    // MARK: - USER
    
    static let signInWithAppleURL = baseURL + "auth/apple/callback"
    static let profileInputURL = baseURL + "auth/inputProfile"
    static let JWTRefreshURL = baseURL + "renew-access-token"
    static let validateTokenURL = baseURL + "validate-token"
    static let revokeTokenURL = baseURL + "revoke"
    
    static let getProfileURL = baseURL + "profile"   // + /userId?
    static let updateProfileURL = baseURL + "update"
    
    static let getListUsersURL = baseURL + "list/users"
    
    // MARK: - BOOK
    
    static let searchBookURL = baseURL + "book/search" // + query
    static let recommendBooksURL = baseURL + "book/todayBooks"
    
    // MARK: - BOOKSTORY
    
    static let createStoryURL = baseURL + "bookstories/createBookStory"
    static let getUserStoryCount = baseURL + "bookstories/count"    // + /userId?
    static let getPublicStoryURL = baseURL + "bookstories/public"   // ?page=2&pageSize=10
    static let getFriendStoryURL = baseURL + "bookstories/friend"  // + /friendID
    static let getMyStoryURL = baseURL + "bookstories/my"
    
    // 키워드 검색
    static let getAllPublicStoriesKeywordURL = baseURL + "bookstories/public/search"
    static let getFriendPublicStoriesKeywordURL = baseURL + "bookstories/friend/search"     // :friendID
    static let getMyStoriesKeywordURL = baseURL + "bookstories/my/search"

    static let updateStoryURL = baseURL + "bookstories/update"    // + /storyID
    static let fetchSpecificStoryURL = baseURL + "bookstories"
    static let deleteStoryURL = baseURL + "bookstories/delete"    // + /storyID
    static let deleteMultipleStoryURL = baseURL + "bookstories/delete-multiple"    // + json 으로 storyId 들 받음
    
    // MARK: - BOOKSTORY COMMENT
    
    static let addCommentToStoryURL = baseURL + "bookstoriesComments"
    static let getCommentForStoryURL = baseURL + "bookstoriesComments"    // + /bookStoryId
    static let getCommentCountForStoryURL = baseURL + "bookstoriesComments/count"   // + /bookStoryId
    static let deleteCommentStoryURL = baseURL + "bookstoriesComments"    // + /commentId
    
    // MARK: - FOLDER
    
    // 폴더별 조회
    static let getAllPublicStoriesByFolderURL = baseURL + "folder/public"   // + /:folderId
    static let getFriendPublicStoriesByFolderURL = baseURL + "folder/friend"    // + /:friendId/:folderId
    static let getMyStoriesByFolderURL = baseURL + "folder/my"  // + /folderId
    
    static let createFolderURL = baseURL + "folder/create"
    
    // 폴더 목록 조회
    static let getAllFoldersURL = baseURL + "folder/all"
    static let getUserFoldersURL = baseURL + "folder/user"  // + /userId
    static let getMyFoldersURL = baseURL + "folder/myfolder"
    
    static let updateFolderURL = baseURL + "folder/update"  // + /folderId
    static let deleteFolderURL = baseURL + "folder/delete"  // + /folderId

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
