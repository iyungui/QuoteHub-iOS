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
final class MockAPIClient: APIClient {

    // MARK: - Properties

    /// 테스트에서 설정할 Mock 응답
    var mockResponse: Any?

    /// 테스트에서 설정할 Mock 에러
    var mockError: Error?

    /// request 메서드가 호출되었는지 확인
    var requestCalled: Bool = false

    /// 마지막으로 호출된 endpoint
    var lastEndpoint: EndpointProtocol?

    /// 마지막으로 호출된 body
    var lastBody: RequestBody?

    // MARK: - Initialization

    override init() {
        // 참고: APIClient는 private init()이므로,
        // 실제로는 APIClient를 protocol로 만들어야 합니다.
        // 여기서는 테스트 학습 목적으로 간단히 구현합니다.
        fatalError("MockAPIClient는 protocol 기반 설계가 필요합니다. 현재는 validation 테스트만 지원됩니다.")
    }
}

// MARK: - 설명 주석
/*

 ## Mock을 사용한 통합 테스트 구현 방법

 현재 APIClient는 final class로 구현되어 있어 직접 Mock을 만들기 어렵습니다.
 실제 프로덕션 코드에서 Mock 테스트를 구현하려면 다음과 같은 리팩토링이 필요합니다:

 ### 1. Protocol 기반 설계로 변경

 ```swift
 // APIClient.swift
 protocol APIClientProtocol {
     func request<T: APIResponseProtocol & Codable>(
         endpoint: EndpointProtocol,
         body: RequestBody,
         responseType: T.Type,
         customHeaders: [String: String]?,
         isRetry: Bool
     ) async throws -> T
 }

 final class APIClient: APIClientProtocol {
     // 기존 구현 유지
 }
 ```

 ### 2. BookStoryService에 의존성 주입

 ```swift
 // BookStoryService.swift
 final class BookStoryService: BookStoryServiceProtocol {
     private let apiClient: APIClientProtocol  // Protocol 타입으로 변경

     init(apiClient: APIClientProtocol = APIClient.shared) {
         self.apiClient = apiClient
     }
 }
 ```

 ### 3. MockAPIClient 구현

 ```swift
 // MockAPIClient.swift
 final class MockAPIClient: APIClientProtocol {
     var mockResponse: Any?
     var mockError: Error?

     func request<T: APIResponseProtocol & Codable>(
         endpoint: EndpointProtocol,
         body: RequestBody,
         responseType: T.Type,
         customHeaders: [String: String]?,
         isRetry: Bool
     ) async throws -> T {
         // Mock 에러가 설정되어 있으면 에러 던지기
         if let error = mockError {
             throw error
         }

         // Mock 응답 반환
         guard let response = mockResponse as? T else {
             fatalError("Mock response type mismatch")
         }
         return response
     }
 }
 ```

 ### 4. 통합 테스트 작성 예시

 ```swift
 func testCreateBookStory_WithValidData_Success() async throws {
     // Given: MockAPIClient 설정
     let mockClient = MockAPIClient()
     let service = BookStoryService(apiClient: mockClient)

     // Mock 응답 데이터 생성
     let mockUser = User(...)
     let mockBook = Book(...)
     let mockBookStory = BookStory(...)
     let mockResponse = APIResponse(
         success: true,
         message: "북스토리가 생성되었습니다",
         data: mockBookStory
     )

     mockClient.mockResponse = mockResponse

     // When: createBookStory 호출
     let quotes = [Quote(id: UUID(), quote: "테스트 문장", page: 1)]
     let result = try await service.createBookStory(
         images: nil,
         bookId: "book123",
         quotes: quotes,
         content: "테스트 내용",
         isPublic: true,
         keywords: ["테스트"],
         themeIds: ["theme1"]
     )

     // Then: 결과 검증
     XCTAssertTrue(result.success)
     XCTAssertEqual(result.data?._id, mockBookStory._id)
 }
 ```

 ### 5. 현재 상태에서 가능한 테스트

 현재는 **4단계에서 작성한 validation 테스트**만 가능합니다.
 이는 실제 API 호출 전에 발생하는 에러를 테스트하므로 Mock이 필요없습니다.

 완전한 통합 테스트를 위해서는 위의 리팩토링이 필요하며,
 이는 프로젝트 전체의 아키텍처 변경을 수반하므로 별도의 작업이 필요합니다.

 */
