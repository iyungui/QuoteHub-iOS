//
//  APIResponse.swift
//  QuoteHub
//
//  Created by 이융의 on 10/15/23.
//

import Foundation


struct BackendErrorResponse: Codable {
    let error: String
}

struct DeleteResponse: Codable {
    let success: Bool
    let message: String
}

