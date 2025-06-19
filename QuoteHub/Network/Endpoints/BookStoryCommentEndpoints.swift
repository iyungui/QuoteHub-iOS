//
//  BookStoryCommentEndpoints.swift
//  QuoteHub
//
//  Created by 이융의 on 6/19/25.
//

import Foundation

enum BookStoryCommentEndpoints: EndpointProtocol {
    // 댓글 생성, 수정, 삭제
    case addComment
    case updateComment(commentId: String)
    case deleteComment(commentId: String)
    
    // 댓글 조회
    case getCommentsForStory(bookStoryId: String, page: Int, pageSize: Int)
    case getCommentCountForStory(bookStoryId: String)
    
    var path: String {
        switch self {
        case .addComment:
            return "/bookstoriesComments"
        case .updateComment(let commentId):
            return "/bookstoriesComments/\(commentId)"
        case .deleteComment(let commentId):
            return "/bookstoriesComments/\(commentId)"
        case .getCommentsForStory(let bookStoryId, let page, let pageSize):
            return "/bookstoriesComments/\(bookStoryId)?page=\(page)&pageSize=\(pageSize)"
        case .getCommentCountForStory(let bookStoryId):
            return "/bookstoriesComments/count/\(bookStoryId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .addComment:
            return .POST
        case .updateComment:
            return .PUT
        case .deleteComment:
            return .DELETE
        case .getCommentsForStory, .getCommentCountForStory:
            return .GET
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .addComment, .updateComment, .deleteComment:
            return true
        case .getCommentsForStory, .getCommentCountForStory:
            return false
        }
    }
}
