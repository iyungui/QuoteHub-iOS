//
//  MockAPIClient.swift
//  QuoteHubTests
//
//  Created by Claude on 10/22/25.
//

import Foundation
@testable import QuoteHub

/// 테스트용 Mock APIClient
/// 실제 네트워크 호출 없이 미리 설정된 응답을 반환합니다.
final class MockAPIClient: APIClientProtocol {
    var mockResponse: Any?
    var mockError: Error?
    
    var lastEndpoint: EndpointProtocol?

    var lastBody: RequestBody?

    // MARK: - Initialization

    init() {
        // MockAPIClient는 protocol을 구현하므로 초기화 가능
    }

    // MARK: - APIClientProtocol Implementation

    func request<T: APIResponseProtocol & Codable>(
        endpoint: EndpointProtocol,
        body: RequestBody,
        responseType: T.Type,
        customHeaders: [String: String]?,
        isRetry: Bool
    ) async throws -> T {
        // 호출 기록
        lastEndpoint = endpoint
        lastBody = body

        // Mock 에러가 설정되어 있으면 에러 던지기
        if let error = mockError {
            throw error
        }

        // Mock 응답 반환
        guard let response = mockResponse as? T else {
            fatalError("Mock response가 설정되지 않았거나 타입이 맞지 않습니다. 예상 타입: \(T.self)")
        }

        return response
    }
}
