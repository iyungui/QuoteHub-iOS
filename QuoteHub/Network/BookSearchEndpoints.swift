//
//  BookSearchEndpoints.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import Foundation

enum BookSearchEndpoints: EndpointProtocol {
    case searchBook(query: String, page: Int)
    case recommendBooks
    
    var path: String {
        switch self {
        case .searchBook(let query, let page):
            // url 인코딩하여 서버에 올바르게 요청하도록
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return "/book/search?query=\(encodedQuery)&page=\(page)"
        case .recommendBooks:
            return "/book/todayBooks"
        }
    }
    
    var method: HTTPMethod {
        return .GET
    }
    
    // 책 검색, 추천 책 조회는 인증 필요 x
    var requiresAuth: Bool {
        return false
    }
}
