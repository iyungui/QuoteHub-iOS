//
//  NetworkError.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case unauthorized
    case serverError(Int, String)
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .noData:
            return "서버로부터 데이터를 받지 못했습니다."
        case .invalidResponse:
            return "잘못된 응답 형식입니다."
        case .unauthorized:
            return "인증이 필요합니다."
        case .serverError(let code, let message):
            return "서버 오류 (\(code)): \(message)"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError(let error):
            return "데이터 파싱 오류: \(error.localizedDescription)"
        }
    }
}
