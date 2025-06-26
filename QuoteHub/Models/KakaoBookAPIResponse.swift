//
//  KakaoBookAPIResponse.swift
//  QuoteHub
//
//  Created by 이융의 on 6/26/25.
//

import Foundation

// Kakao Book Search API Response
struct BooksResponse: Codable {
    let documents: [Book]
    let meta: Meta
}

struct Meta: Codable {
    let is_end: Bool
    let pageable_count: Int
    let total_count: Int
}
