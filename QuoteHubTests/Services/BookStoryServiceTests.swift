//
//  BookStoryServiceTests.swift
//  QuoteHubTests
//
//  Created by Claude on 10/22/25.
//

import XCTest
@testable import QuoteHub

final class BookStoryServiceTests: XCTestCase {

    // MARK: - Properties

    var service: BookStoryService!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Note: 실제 APIClient를 주입하지만, validation 테스트에서는 네트워크 호출 전에 에러 발생
        service = BookStoryService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - CreateBookStory Validation Tests

    /// 테스트 1: createBookStory - quotes가 비어있을 때 에러 발생
    func testCreateBookStory_WithEmptyQuotes_ThrowsError() async {
        // Given: 빈 quotes 배열
        let emptyQuotes: [Quote] = []

        // When & Then: createBookStory 호출 시 에러 발생
        do {
            _ = try await service.createBookStory(
                images: nil,
                bookId: "book123",
                quotes: emptyQuotes,
                content: nil,
                isPublic: true,
                keywords: nil,
                themeIds: nil
            )
            XCTFail("빈 quotes 배열로 createBookStory 호출 시 에러가 발생해야 함")
        } catch let error as NetworkError {
            // 성공: NetworkError가 발생해야 함
            if case .serverError(let code, let message) = error {
                XCTAssertEqual(code, 400, "에러 코드는 400이어야 함")
                XCTAssertEqual(message, "최소 하나의 문장이 필요합니다.", "적절한 에러 메시지가 표시되어야 함")
            } else {
                XCTFail("serverError(400)이 발생해야 함")
            }
        } catch {
            XCTFail("NetworkError가 발생해야 하지만 다른 에러 발생: \(error)")
        }
    }

    /// 테스트 2: createBookStory - 빈 문장 포함 시 에러 발생
    func testCreateBookStory_WithEmptyQuoteContent_ThrowsError() async {
        // Given: 빈 문장이 포함된 quotes
        let quotesWithEmpty = [
            Quote(id: UUID(), quote: "정상 문장", page: nil),
            Quote(id: UUID(), quote: "   ", page: nil),  // 공백만
            Quote(id: UUID(), quote: "또 다른 정상 문장", page: nil)
        ]

        // When & Then: createBookStory 호출 시 에러 발생
        do {
            _ = try await service.createBookStory(
                images: nil,
                bookId: "book123",
                quotes: quotesWithEmpty,
                content: nil,
                isPublic: true,
                keywords: nil,
                themeIds: nil
            )
            XCTFail("빈 문장이 포함된 quotes로 createBookStory 호출 시 에러가 발생해야 함")
        } catch let error as NetworkError {
            // 성공: NetworkError가 발생해야 함
            if case .serverError(let code, let message) = error {
                XCTAssertEqual(code, 400, "에러 코드는 400이어야 함")
                XCTAssertEqual(message, "문장 내용은 비어있을 수 없습니다.", "적절한 에러 메시지가 표시되어야 함")
            } else {
                XCTFail("serverError(400)이 발생해야 함")
            }
        } catch {
            XCTFail("NetworkError가 발생해야 하지만 다른 에러 발생: \(error)")
        }
    }

    /// 테스트 3: createBookStory - 완전히 빈 문자열 포함 시 에러 발생
    func testCreateBookStory_WithCompletelyEmptyQuote_ThrowsError() async {
        // Given: 완전히 빈 문장 포함
        let quotesWithEmpty = [
            Quote(id: UUID(), quote: "", page: nil)  // 빈 문자열
        ]

        // When & Then: createBookStory 호출 시 에러 발생
        do {
            _ = try await service.createBookStory(
                images: nil,
                bookId: "book123",
                quotes: quotesWithEmpty,
                content: nil,
                isPublic: true,
                keywords: nil,
                themeIds: nil
            )
            XCTFail("빈 문장으로 createBookStory 호출 시 에러가 발생해야 함")
        } catch let error as NetworkError {
            // 성공: NetworkError가 발생해야 함
            if case .serverError(let code, let message) = error {
                XCTAssertEqual(code, 400, "에러 코드는 400이어야 함")
                XCTAssertEqual(message, "문장 내용은 비어있을 수 없습니다.", "적절한 에러 메시지가 표시되어야 함")
            } else {
                XCTFail("serverError(400)이 발생해야 함")
            }
        } catch {
            XCTFail("NetworkError가 발생해야 하지만 다른 에러 발생: \(error)")
        }
    }

    // MARK: - UpdateBookStory Validation Tests

    /// 테스트 4: updateBookStory - quotes가 비어있을 때 에러 발생
    func testUpdateBookStory_WithEmptyQuotes_ThrowsError() async {
        // Given: 빈 quotes 배열
        let emptyQuotes: [Quote] = []

        // When & Then: updateBookStory 호출 시 에러 발생
        do {
            _ = try await service.updateBookStory(
                storyId: "story123",
                quotes: emptyQuotes,
                images: nil,
                content: nil,
                isPublic: true,
                keywords: nil,
                themeIds: nil
            )
            XCTFail("빈 quotes 배열로 updateBookStory 호출 시 에러가 발생해야 함")
        } catch let error as NetworkError {
            // 성공: NetworkError가 발생해야 함
            if case .serverError(let code, let message) = error {
                XCTAssertEqual(code, 400, "에러 코드는 400이어야 함")
                XCTAssertEqual(message, "최소 하나의 문장이 필요합니다.", "적절한 에러 메시지가 표시되어야 함")
            } else {
                XCTFail("serverError(400)이 발생해야 함")
            }
        } catch {
            XCTFail("NetworkError가 발생해야 하지만 다른 에러 발생: \(error)")
        }
    }

    /// 테스트 5: updateBookStory - 빈 문장 포함 시 에러 발생
    func testUpdateBookStory_WithEmptyQuoteContent_ThrowsError() async {
        // Given: 빈 문장이 포함된 quotes
        let quotesWithEmpty = [
            Quote(id: UUID(), quote: "정상 문장", page: nil),
            Quote(id: UUID(), quote: "\n\n", page: nil),  // 줄바꿈만
            Quote(id: UUID(), quote: "또 다른 정상 문장", page: nil)
        ]

        // When & Then: updateBookStory 호출 시 에러 발생
        do {
            _ = try await service.updateBookStory(
                storyId: "story123",
                quotes: quotesWithEmpty,
                images: nil,
                content: nil,
                isPublic: true,
                keywords: nil,
                themeIds: nil
            )
            XCTFail("빈 문장이 포함된 quotes로 updateBookStory 호출 시 에러가 발생해야 함")
        } catch let error as NetworkError {
            // 성공: NetworkError가 발생해야 함
            if case .serverError(let code, let message) = error {
                XCTAssertEqual(code, 400, "에러 코드는 400이어야 함")
                XCTAssertEqual(message, "문장 내용은 비어있을 수 없습니다.", "적절한 에러 메시지가 표시되어야 함")
            } else {
                XCTFail("serverError(400)이 발생해야 함")
            }
        } catch {
            XCTFail("NetworkError가 발생해야 하지만 다른 에러 발생: \(error)")
        }
    }

    // MARK: - Edge Case Tests

    /// 테스트 6: createBookStory - 여러 개의 빈 문장이 섞여있을 때 (첫 번째 빈 문장에서 에러)
    func testCreateBookStory_WithMultipleEmptyQuotes_ThrowsErrorAtFirst() async {
        // Given: 여러 빈 문장 포함
        let quotesWithMultipleEmpty = [
            Quote(id: UUID(), quote: "정상", page: nil),
            Quote(id: UUID(), quote: "", page: nil),      // 첫 번째 빈 문장
            Quote(id: UUID(), quote: "   ", page: nil),   // 두 번째 빈 문장
            Quote(id: UUID(), quote: "정상2", page: nil)
        ]

        // When & Then: 첫 번째 빈 문장에서 에러 발생
        do {
            _ = try await service.createBookStory(
                images: nil,
                bookId: "book123",
                quotes: quotesWithMultipleEmpty,
                content: nil,
                isPublic: true,
                keywords: nil,
                themeIds: nil
            )
            XCTFail("빈 문장이 포함된 경우 에러가 발생해야 함")
        } catch let error as NetworkError {
            if case .serverError(let code, let message) = error {
                XCTAssertEqual(code, 400)
                XCTAssertEqual(message, "문장 내용은 비어있을 수 없습니다.")
            } else {
                XCTFail("serverError(400)이 발생해야 함")
            }
        } catch {
            XCTFail("NetworkError가 발생해야 함: \(error)")
        }
    }

    /// 테스트 7: Quote 내용 validation - 탭 문자만 포함된 경우
    func testCreateBookStory_WithTabOnlyQuote_ThrowsError() async {
        // Given: 탭 문자만 포함된 Quote
        let quotesWithTab = [
            Quote(id: UUID(), quote: "\t\t\t", page: nil)  // 탭만
        ]

        // When & Then: 에러 발생
        do {
            _ = try await service.createBookStory(
                images: nil,
                bookId: "book123",
                quotes: quotesWithTab,
                content: nil,
                isPublic: true,
                keywords: nil,
                themeIds: nil
            )
            XCTFail("공백 문자만 포함된 Quote는 에러를 발생시켜야 함")
        } catch let error as NetworkError {
            if case .serverError(let code, _) = error {
                XCTAssertEqual(code, 400, "400 에러가 발생해야 함")
            } else {
                XCTFail("serverError(400)이 발생해야 함")
            }
        } catch {
            XCTFail("NetworkError가 발생해야 함")
        }
    }

    // MARK: - Integration Tests with Mock (예시)

    /// 테스트 8: MockAPIClient를 사용한 통합 테스트 예시
    /// 참고: 실제로 실행하려면 User, Book 모델이 필요하므로 주석 처리됨
    /*
    func testCreateBookStory_WithMockClient_Success() async throws {
        // Given: MockAPIClient 설정
        let mockClient = MockAPIClient()
        let mockService = BookStoryService(apiClient: mockClient)

        // Mock User 생성
        let mockUser = User(
            _id: "user123",
            name: "테스트유저",
            email: "test@example.com",
            profileImage: nil,
            createdAt: "2023-01-01",
            isPremium: false,
            premiumExpiresAt: nil
        )

        // Mock Book 생성
        let mockBook = Book(
            _id: "book123",
            title: "테스트 책",
            author: "저자",
            bookImageURL: nil,
            createdAt: "2023-01-01"
        )

        // Mock BookStory 생성
        let mockQuotes = [Quote(id: UUID(), quote: "테스트 문장", page: 1)]
        let mockBookStory = BookStory(
            _id: "story123",
            userId: mockUser,
            bookId: mockBook,
            quotes: mockQuotes,
            content: "테스트 내용",
            storyImageURLs: nil,
            isPublic: true,
            createdAt: "2023-01-01",
            updatedAt: "2023-01-01",
            keywords: ["테스트"],
            themeIds: ["theme1"]
        )

        // Mock 응답 설정
        let mockResponse = APIResponse<BookStory>(
            success: true,
            message: "북스토리가 생성되었습니다",
            data: mockBookStory
        )
        mockClient.mockResponse = mockResponse

        // When: createBookStory 호출
        let result = try await mockService.createBookStory(
            images: nil,
            bookId: "book123",
            quotes: mockQuotes,
            content: "테스트 내용",
            isPublic: true,
            keywords: ["테스트"],
            themeIds: ["theme1"]
        )

        // Then: 결과 검증
        XCTAssertTrue(result.success, "응답의 success는 true여야 함")
        XCTAssertEqual(result.message, "북스토리가 생성되었습니다")
        XCTAssertNotNil(result.data, "BookStory 데이터가 반환되어야 함")
        XCTAssertEqual(result.data?._id, "story123", "생성된 BookStory의 ID가 일치해야 함")

        // Mock 호출 검증
        XCTAssertTrue(mockClient.requestCalled, "APIClient의 request 메서드가 호출되어야 함")
        XCTAssertNotNil(mockClient.lastEndpoint, "endpoint가 기록되어야 함")
    }
    */
}

