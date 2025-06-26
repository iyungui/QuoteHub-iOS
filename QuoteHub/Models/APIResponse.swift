//
//  APIResponse.swift
//  QuoteHub
//
//  Created by 이융의 on 10/15/23.
//

import Foundation

// MARK: - Base Response Models
/// 모든 API에서 사용하는 공통 구조 정의
protocol APIResponseProtocol {
    var success: Bool { get }
    var message: String { get }
}

struct APIResponse<T: Codable>: Codable, APIResponseProtocol {
    let success: Bool
    let message: String
    let data: T?
    let errors: [String: String]?
}

struct Pagination: Codable {
    let currentPage: Int
    let totalPages: Int
    let pageSize: Int
    let totalItems: Int
}

struct PaginatedAPIResponse<T: Codable>: Codable, APIResponseProtocol {
    let success: Bool
    let message: String
    let data: [T]
    let pagination: Pagination
}

/// data를 전달하지 않는 api 위한 모델
struct EmptyData: Codable {}
