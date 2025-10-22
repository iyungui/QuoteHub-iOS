//
//  StoryFormViewModelTests.swift
//  QuoteHubTests
//
//  Created by Claude on 10/22/25.
//

import XCTest
@testable import QuoteHub

@MainActor
final class StoryFormViewModelTests: XCTestCase {

    // MARK: - Properties

    var viewModel: StoryFormViewModel!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        viewModel = StoryFormViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Keyword Validation Tests

    /// 테스트 1: 정상적인 키워드 추가 (8자 이하)
    func testAddKeyword_WithValidLength_Success() {
        // Given: 빈 키워드 배열
        XCTAssertEqual(viewModel.keywords.count, 0, "초기 키워드 배열은 비어있어야 함")

        // When: 8자 이하 키워드 입력 (띄어쓰기로 추가 트리거)
        viewModel.inlineKeywordInput = "#독서 "
        viewModel.processInlineKeywordInput(viewModel.inlineKeywordInput)

        // Then: 키워드가 정상적으로 추가됨
        XCTAssertEqual(viewModel.keywords.count, 1, "키워드가 1개 추가되어야 함")
        XCTAssertTrue(viewModel.keywords.contains("독서"), "keywords 배열에 '독서'가 있어야 함")
        XCTAssertEqual(viewModel.inlineKeywordInput, "", "입력 필드가 초기화되어야 함")
    }

    /// 테스트 2: 8자 초과 키워드 추가 실패
    func testAddKeyword_ExceedsMaxLength_Fails() {
        // Given: 빈 키워드 배열
        XCTAssertEqual(viewModel.keywords.count, 0)

        // When: 9자 키워드 입력 시도
        viewModel.inlineKeywordInput = "#아주긴키워드네요 "
        viewModel.processInlineKeywordInput(viewModel.inlineKeywordInput)

        // Then: 키워드가 추가되지 않음
        XCTAssertEqual(viewModel.keywords.count, 0, "8자 초과 키워드는 추가되지 않아야 함")
        XCTAssertNotNil(viewModel.inlineKeywordFeedback, "피드백 메시지가 표시되어야 함")
        XCTAssertTrue(
            viewModel.inlineKeywordFeedback?.contains("8자 이내") ?? false,
            "8자 제한 피드백이 표시되어야 함"
        )
    }

    /// 테스트 3: 중복 키워드 추가 실패
    func testAddKeyword_Duplicate_Fails() {
        // Given: "독서" 키워드가 이미 존재
        viewModel.keywords = ["독서"]

        // When: 동일한 "독서" 키워드 추가 시도
        viewModel.inlineKeywordInput = "#독서 "
        viewModel.processInlineKeywordInput(viewModel.inlineKeywordInput)

        // Then: 키워드가 추가되지 않음
        XCTAssertEqual(viewModel.keywords.count, 1, "중복 키워드는 추가되지 않아야 함")
        XCTAssertNotNil(viewModel.inlineKeywordFeedback, "피드백 메시지가 표시되어야 함")
        XCTAssertTrue(
            viewModel.inlineKeywordFeedback?.contains("이미 추가된") ?? false,
            "중복 키워드 피드백이 표시되어야 함"
        )
    }

    /// 테스트 4: 최대 10개 초과 키워드 추가 실패
    func testAddKeyword_ExceedsMaxCount_Fails() {
        // Given: 이미 10개의 키워드 존재
        viewModel.keywords = (1...10).map { "키워드\($0)" }
        XCTAssertEqual(viewModel.keywords.count, 10)

        // When: 11번째 키워드 추가 시도
        viewModel.inlineKeywordInput = "#신규키워드 "
        viewModel.processInlineKeywordInput(viewModel.inlineKeywordInput)

        // Then: 키워드가 추가되지 않음
        XCTAssertEqual(viewModel.keywords.count, 10, "10개 초과 키워드는 추가되지 않아야 함")
        XCTAssertNotNil(viewModel.inlineKeywordFeedback, "피드백 메시지가 표시되어야 함")
        XCTAssertTrue(
            viewModel.inlineKeywordFeedback?.contains("최대 10개") ?? false,
            "최대 개수 제한 피드백이 표시되어야 함"
        )
    }

    /// 테스트 5: 빈 키워드 입력 시 조용히 무시
    func testAddKeyword_Empty_SilentlyIgnored() {
        // Given: 빈 키워드 배열
        XCTAssertEqual(viewModel.keywords.count, 0)

        // When: 빈 키워드 입력 ("# " 또는 "#")
        viewModel.inlineKeywordInput = "# "
        viewModel.processInlineKeywordInput(viewModel.inlineKeywordInput)

        // Then: 아무 동작 없음 (피드백 메시지도 없음)
        XCTAssertEqual(viewModel.keywords.count, 0, "빈 키워드는 추가되지 않아야 함")
        XCTAssertNil(viewModel.inlineKeywordFeedback, "빈 키워드는 피드백 없이 무시되어야 함")
        XCTAssertEqual(viewModel.inlineKeywordInput, "", "입력 필드가 초기화되어야 함")
    }

    /// 테스트 6: 키워드 삭제
    func testRemoveKeyword_Success() {
        // Given: 3개의 키워드 존재
        viewModel.keywords = ["독서", "성장", "여행"]

        // When: "성장" 키워드 삭제
        viewModel.removeInlineKeyword("성장")

        // Then: 해당 키워드만 삭제됨
        XCTAssertEqual(viewModel.keywords.count, 2, "키워드가 1개 삭제되어야 함")
        XCTAssertFalse(viewModel.keywords.contains("성장"), "'성장' 키워드가 삭제되어야 함")
        XCTAssertTrue(viewModel.keywords.contains("독서"), "'독서' 키워드는 유지되어야 함")
        XCTAssertTrue(viewModel.keywords.contains("여행"), "'여행' 키워드는 유지되어야 함")
    }

    /// 테스트 7: 존재하지 않는 키워드 삭제 시도 (안전성 테스트)
    func testRemoveKeyword_NonExistent_NoEffect() {
        // Given: 1개의 키워드 존재
        viewModel.keywords = ["독서"]

        // When: 존재하지 않는 키워드 삭제 시도
        viewModel.removeInlineKeyword("비존재")

        // Then: 아무 변화 없음
        XCTAssertEqual(viewModel.keywords.count, 1, "키워드 개수는 변하지 않아야 함")
        XCTAssertTrue(viewModel.keywords.contains("독서"), "기존 키워드는 유지되어야 함")
    }

    /// 테스트 8: 정확히 8자 키워드 추가 성공 (경계값 테스트)
    func testAddKeyword_ExactlyEightCharacters_Success() {
        // Given: 빈 키워드 배열
        XCTAssertEqual(viewModel.keywords.count, 0)

        // When: 정확히 8자 키워드 입력
        let eightCharKeyword = "여덟글자임"  // 5자
        // "테스트키워드" = 6자
        let exactEightChar = "여덟글자키워드"  // 7자... 한글은 1글자당 1자
        // 정확히 8자를 만들기 위해: "여덟글자완성됨" = 7자
        // "키워드여덟글자" = 7자
        let keyword8 = "독서성장여행책" // 7자
        let realEight = "독서성장여행책임" // 8자

        viewModel.inlineKeywordInput = "#\(realEight) "
        viewModel.processInlineKeywordInput(viewModel.inlineKeywordInput)

        // Then: 키워드가 정상 추가됨
        XCTAssertEqual(viewModel.keywords.count, 1, "8자 키워드는 정상 추가되어야 함")
        XCTAssertTrue(viewModel.keywords.contains(realEight), "8자 키워드가 배열에 있어야 함")
    }

    /// 테스트 9: 여러 키워드 연속 추가
    func testAddMultipleKeywords_Success() {
        // Given: 빈 키워드 배열
        XCTAssertEqual(viewModel.keywords.count, 0)

        // When: 여러 키워드를 연속으로 추가
        let keywordsToAdd = ["독서", "성장", "여행"]
        for keyword in keywordsToAdd {
            viewModel.inlineKeywordInput = "#\(keyword) "
            viewModel.processInlineKeywordInput(viewModel.inlineKeywordInput)
        }

        // Then: 모든 키워드가 추가됨
        XCTAssertEqual(viewModel.keywords.count, 3, "3개의 키워드가 추가되어야 함")
        XCTAssertTrue(viewModel.keywords.contains("독서"))
        XCTAssertTrue(viewModel.keywords.contains("성장"))
        XCTAssertTrue(viewModel.keywords.contains("여행"))
    }

    /// 테스트 10: 줄바꿈으로도 키워드 추가 가능
    func testAddKeyword_WithNewline_Success() {
        // Given: 빈 키워드 배열
        XCTAssertEqual(viewModel.keywords.count, 0)

        // When: 줄바꿈으로 키워드 추가
        viewModel.inlineKeywordInput = "#독서\n"
        viewModel.processInlineKeywordInput(viewModel.inlineKeywordInput)

        // Then: 키워드가 정상 추가됨
        XCTAssertEqual(viewModel.keywords.count, 1, "줄바꿈으로도 키워드가 추가되어야 함")
        XCTAssertTrue(viewModel.keywords.contains("독서"))
    }

    // MARK: - Quote Management Tests

    /// 테스트 11: Quote 추가
    func testAddQuote_Success() {
        // Given: 초기 1개의 빈 Quote 존재
        XCTAssertEqual(viewModel.quotes.count, 1, "초기에 1개의 빈 Quote가 있어야 함")

        // When: Quote 추가
        viewModel.addQuote()

        // Then: Quote가 추가됨
        XCTAssertEqual(viewModel.quotes.count, 2, "Quote가 1개 추가되어 총 2개가 되어야 함")
    }

    /// 테스트 12: 특정 위치에 Quote 추가
    func testAddQuote_AtSpecificIndex_Success() {
        // Given: 3개의 Quote 존재
        viewModel.quotes = [
            Quote(id: UUID(), quote: "첫 번째", page: nil),
            Quote(id: UUID(), quote: "두 번째", page: nil),
            Quote(id: UUID(), quote: "세 번째", page: nil)
        ]

        // When: 인덱스 1 (두 번째) 다음에 Quote 추가
        viewModel.addQuote(at: 1)

        // Then: 총 4개의 Quote가 되고, 인덱스 2에 빈 Quote 삽입됨
        XCTAssertEqual(viewModel.quotes.count, 4, "Quote가 1개 추가되어 총 4개가 되어야 함")
        XCTAssertEqual(viewModel.quotes[0].quote, "첫 번째")
        XCTAssertEqual(viewModel.quotes[1].quote, "두 번째")
        XCTAssertEqual(viewModel.quotes[2].quote, "", "인덱스 2에 빈 Quote가 추가되어야 함")
        XCTAssertEqual(viewModel.quotes[3].quote, "세 번째")
    }

    /// 테스트 13: Quote 삭제 - 2개 이상일 때 성공
    func testRemoveQuote_WhenMultipleQuotes_Success() {
        // Given: 3개의 Quote 존재
        let quote1 = Quote(id: UUID(), quote: "첫 번째", page: nil)
        let quote2 = Quote(id: UUID(), quote: "두 번째", page: nil)
        let quote3 = Quote(id: UUID(), quote: "세 번째", page: nil)
        viewModel.quotes = [quote1, quote2, quote3]

        // When: 인덱스 1 (두 번째) Quote 삭제
        viewModel.removeQuote(at: 1)

        // Then: Quote가 삭제되어 2개만 남음
        XCTAssertEqual(viewModel.quotes.count, 2, "Quote가 1개 삭제되어 2개가 남아야 함")
        XCTAssertEqual(viewModel.quotes[0].quote, "첫 번째")
        XCTAssertEqual(viewModel.quotes[1].quote, "세 번째")
    }

    /// 테스트 14: Quote 삭제 - 1개만 남았을 때 삭제 불가 (최소 1개 유지)
    func testRemoveQuote_WhenOnlyOneQuote_CannotRemove() {
        // Given: 1개의 Quote만 존재
        viewModel.quotes = [Quote(id: UUID(), quote: "유일한 문장", page: nil)]
        XCTAssertEqual(viewModel.quotes.count, 1)

        // When: 마지막 Quote 삭제 시도
        viewModel.removeQuote(at: 0)

        // Then: Quote가 삭제되지 않고 여전히 1개 유지
        XCTAssertEqual(viewModel.quotes.count, 1, "최소 1개의 Quote는 유지되어야 함")
        XCTAssertEqual(viewModel.quotes[0].quote, "유일한 문장")
    }

    /// 테스트 15: Quote 삭제 - 잘못된 인덱스 (안전성 테스트)
    func testRemoveQuote_InvalidIndex_NoEffect() {
        // Given: 2개의 Quote 존재
        viewModel.quotes = [
            Quote(id: UUID(), quote: "첫 번째", page: nil),
            Quote(id: UUID(), quote: "두 번째", page: nil)
        ]

        // When: 존재하지 않는 인덱스로 삭제 시도
        viewModel.removeQuote(at: 5)

        // Then: 아무 변화 없음
        XCTAssertEqual(viewModel.quotes.count, 2, "잘못된 인덱스는 무시되어야 함")
    }

    /// 테스트 16: isQuotesFilled - 모든 Quote가 비어있을 때
    func testIsQuotesFilled_WhenAllEmpty_ReturnsFalse() {
        // Given: 비어있는 Quote들
        viewModel.quotes = [
            Quote(id: UUID(), quote: "", page: nil),
            Quote(id: UUID(), quote: "   ", page: nil),  // 공백만
            Quote(id: UUID(), quote: "\n", page: nil)     // 줄바꿈만
        ]

        // When & Then: isQuotesFilled는 false 반환
        XCTAssertFalse(viewModel.isQuotesFilled, "모든 Quote가 비어있으면 false를 반환해야 함")
    }

    /// 테스트 17: isQuotesFilled - 최소 1개의 Quote에 텍스트가 있을 때
    func testIsQuotesFilled_WhenAtLeastOneFilled_ReturnsTrue() {
        // Given: 일부 Quote가 채워짐
        viewModel.quotes = [
            Quote(id: UUID(), quote: "", page: nil),
            Quote(id: UUID(), quote: "의미있는 문장", page: nil),  // 채워진 Quote
            Quote(id: UUID(), quote: "   ", page: nil)
        ]

        // When & Then: isQuotesFilled는 true 반환
        XCTAssertTrue(viewModel.isQuotesFilled, "최소 1개의 Quote가 채워져 있으면 true를 반환해야 함")
    }

    /// 테스트 18: Quote의 page 바인딩 업데이트
    func testQuotePageBinding_UpdatesCorrectly() {
        // Given: Quote가 1개 존재
        let quoteId = UUID()
        viewModel.quotes = [Quote(id: quoteId, quote: "테스트 문장", page: nil)]

        // When: pageBinding을 통해 페이지 번호 설정
        let binding = viewModel.pageBinding(for: quoteId)
        binding.wrappedValue = "42"

        // Then: page가 42로 업데이트됨
        XCTAssertEqual(viewModel.quotes[0].page, 42, "페이지 번호가 42로 업데이트되어야 함")
    }

    /// 테스트 19: Quote의 page 바인딩 - 빈 문자열은 nil로 변환
    func testQuotePageBinding_EmptyString_BecomesNil() {
        // Given: page가 42인 Quote
        let quoteId = UUID()
        viewModel.quotes = [Quote(id: quoteId, quote: "테스트 문장", page: 42)]
        XCTAssertEqual(viewModel.quotes[0].page, 42)

        // When: pageBinding을 통해 빈 문자열 설정
        let binding = viewModel.pageBinding(for: quoteId)
        binding.wrappedValue = "   "  // 공백만

        // Then: page가 nil로 업데이트됨
        XCTAssertNil(viewModel.quotes[0].page, "빈 문자열은 nil로 변환되어야 함")
    }

    /// 테스트 20: currentQuote 추가 (문장과 페이지 번호)
    func testAddCurrentQuote_WithPageNumber_Success() {
        // Given: currentQuoteText와 currentQuotePage 설정
        viewModel.quotes = []  // 빈 배열로 시작
        viewModel.currentQuoteText = "새로운 문장입니다"
        viewModel.currentQuotePage = "123"

        // When: addCurrentQuote 호출
        viewModel.addCurrentQuote()

        // Then: Quote가 추가되고 입력 필드가 초기화됨
        XCTAssertEqual(viewModel.quotes.count, 1, "Quote가 1개 추가되어야 함")
        XCTAssertEqual(viewModel.quotes[0].quote, "새로운 문장입니다")
        XCTAssertEqual(viewModel.quotes[0].page, 123)
        XCTAssertEqual(viewModel.currentQuoteText, "", "currentQuoteText가 초기화되어야 함")
        XCTAssertEqual(viewModel.currentQuotePage, "", "currentQuotePage가 초기화되어야 함")
    }

    /// 테스트 21: currentQuote 추가 - 빈 텍스트는 추가되지 않음
    func testAddCurrentQuote_EmptyText_NotAdded() {
        // Given: 빈 currentQuoteText
        viewModel.quotes = []
        viewModel.currentQuoteText = "   "  // 공백만
        viewModel.currentQuotePage = "123"

        // When: addCurrentQuote 호출
        viewModel.addCurrentQuote()

        // Then: Quote가 추가되지 않음
        XCTAssertEqual(viewModel.quotes.count, 0, "빈 텍스트는 Quote로 추가되지 않아야 함")
    }

    // MARK: - Form Validation Tests

    /// 테스트 22: updateFeedbackMessage - quotes가 비어있을 때
    func testUpdateFeedbackMessage_WhenQuotesEmpty_ShowsError() {
        // Given: quotes 배열이 비어있음
        viewModel.quotes = []

        // When: updateFeedbackMessage 호출
        viewModel.updateFeedbackMessage()

        // Then: "문장을 최소 하나 입력해주세요." 피드백 표시
        XCTAssertEqual(
            viewModel.feedbackMessage,
            "문장을 최소 하나 입력해주세요.",
            "quotes가 비어있으면 해당 피드백이 표시되어야 함"
        )
    }

    /// 테스트 23: updateFeedbackMessage - 빈 문장이 포함되어 있을 때
    func testUpdateFeedbackMessage_WhenContainsEmptyQuote_ShowsError() {
        // Given: 일부 Quote가 비어있음
        viewModel.quotes = [
            Quote(id: UUID(), quote: "첫 번째 문장", page: nil),
            Quote(id: UUID(), quote: "   ", page: nil),  // 빈 문장
            Quote(id: UUID(), quote: "세 번째 문장", page: nil)
        ]

        // When: updateFeedbackMessage 호출
        viewModel.updateFeedbackMessage()

        // Then: "빈 문장이 있습니다..." 피드백 표시
        XCTAssertEqual(
            viewModel.feedbackMessage,
            "빈 문장이 있습니다. 내용을 입력해주세요.",
            "빈 Quote가 있으면 해당 피드백이 표시되어야 함"
        )
    }

    /// 테스트 24: updateFeedbackMessage - 모든 문장이 유효할 때
    func testUpdateFeedbackMessage_WhenAllQuotesValid_NoError() {
        // Given: 모든 Quote가 유효한 텍스트를 포함
        viewModel.quotes = [
            Quote(id: UUID(), quote: "첫 번째 문장", page: nil),
            Quote(id: UUID(), quote: "두 번째 문장", page: nil)
        ]

        // When: updateFeedbackMessage 호출
        viewModel.updateFeedbackMessage()

        // Then: feedbackMessage가 nil (에러 없음)
        XCTAssertNil(viewModel.feedbackMessage, "모든 Quote가 유효하면 피드백 메시지가 없어야 함")
    }

    /// 테스트 25: hasValueForDraft - 폼이 완전히 비어있을 때
    func testHasValueForDraft_WhenFormEmpty_ReturnsFalse() {
        // Given: 모든 필드가 비어있음
        viewModel.keywords = []
        viewModel.quotes = [Quote(id: UUID(), quote: "", page: nil)]
        viewModel.content = ""
        viewModel.selectedImages = []

        // When & Then: hasValueForDraft는 false 반환
        XCTAssertFalse(viewModel.hasValueForDraft, "폼이 비어있으면 임시저장 가치가 없어야 함")
    }

    /// 테스트 26: hasValueForDraft - 키워드만 있을 때
    func testHasValueForDraft_WhenOnlyKeywords_ReturnsTrue() {
        // Given: 키워드만 존재
        viewModel.keywords = ["독서"]
        viewModel.quotes = [Quote(id: UUID(), quote: "", page: nil)]
        viewModel.content = ""
        viewModel.selectedImages = []

        // When & Then: hasValueForDraft는 true 반환
        XCTAssertTrue(viewModel.hasValueForDraft, "키워드가 있으면 임시저장 가치가 있어야 함")
    }

    /// 테스트 27: hasValueForDraft - Quote만 있을 때
    func testHasValueForDraft_WhenOnlyQuote_ReturnsTrue() {
        // Given: 유효한 Quote만 존재
        viewModel.keywords = []
        viewModel.quotes = [Quote(id: UUID(), quote: "의미있는 문장", page: nil)]
        viewModel.content = ""
        viewModel.selectedImages = []

        // When & Then: hasValueForDraft는 true 반환
        XCTAssertTrue(viewModel.hasValueForDraft, "Quote가 있으면 임시저장 가치가 있어야 함")
    }

    /// 테스트 28: hasValueForDraft - Content만 있을 때
    func testHasValueForDraft_WhenOnlyContent_ReturnsTrue() {
        // Given: content만 존재
        viewModel.keywords = []
        viewModel.quotes = [Quote(id: UUID(), quote: "", page: nil)]
        viewModel.content = "느낀점을 적었습니다"
        viewModel.selectedImages = []

        // When & Then: hasValueForDraft는 true 반환
        XCTAssertTrue(viewModel.hasValueForDraft, "Content가 있으면 임시저장 가치가 있어야 함")
    }

    /// 테스트 29: hasValueForDraft - 이미지만 있을 때
    func testHasValueForDraft_WhenOnlyImages_ReturnsTrue() {
        // Given: 이미지만 존재
        viewModel.keywords = []
        viewModel.quotes = [Quote(id: UUID(), quote: "", page: nil)]
        viewModel.content = ""
        viewModel.selectedImages = [UIImage()]

        // When & Then: hasValueForDraft는 true 반환
        XCTAssertTrue(viewModel.hasValueForDraft, "이미지가 있으면 임시저장 가치가 있어야 함")
    }

    /// 테스트 30: resetForm - 모든 필드 초기화
    func testResetForm_ClearsAllFields() {
        // Given: 모든 필드에 데이터가 있음
        viewModel.keywords = ["독서", "성장"]
        viewModel.quotes = [
            Quote(id: UUID(), quote: "첫 번째", page: 1),
            Quote(id: UUID(), quote: "두 번째", page: 2)
        ]
        viewModel.content = "느낀점"
        viewModel.selectedImages = [UIImage(), UIImage()]
        viewModel.isPublic = false
        viewModel.themeIds = ["theme1", "theme2"]
        viewModel.inlineKeywordInput = "입력중"
        viewModel.feedbackMessage = "피드백"

        // When: resetForm 호출
        viewModel.resetForm()

        // Then: 모든 필드가 초기화됨
        XCTAssertEqual(viewModel.keywords, [], "keywords가 초기화되어야 함")
        XCTAssertEqual(viewModel.quotes.count, 1, "quotes는 1개의 빈 Quote로 초기화되어야 함")
        XCTAssertEqual(viewModel.quotes[0].quote, "", "초기 Quote는 빈 문자열이어야 함")
        XCTAssertEqual(viewModel.content, "", "content가 초기화되어야 함")
        XCTAssertEqual(viewModel.selectedImages, [], "selectedImages가 초기화되어야 함")
        XCTAssertTrue(viewModel.isPublic, "isPublic이 true로 초기화되어야 함")
        XCTAssertEqual(viewModel.themeIds, [], "themeIds가 초기화되어야 함")
        XCTAssertEqual(viewModel.inlineKeywordInput, "", "inlineKeywordInput이 초기화되어야 함")
        XCTAssertNil(viewModel.feedbackMessage, "feedbackMessage가 nil로 초기화되어야 함")
    }

    // MARK: - Data Loading Tests

    /// 테스트 31: loadFromBookStory - 기존 북스토리 데이터 로드
    func testLoadFromBookStory_LoadsAllFields() {
        // Given: BookStory 객체 생성 (Mock 데이터)
        let mockUser = User(
            _id: "user123",
            nickname: "테스트유저",
            profileImage: "",
            statusMessage: "테스트메시지",
            blockedUsers: nil
        )

        let mockBook = Book(
            _id: "book123",
            title: "테스트 책",
            author: "저자",
            bookImageURL: nil,
            createdAt: "2023-01-01"
        )

        let mockQuotes = [
            Quote(id: UUID(), quote: "로드된 첫 문장", page: 10),
            Quote(id: UUID(), quote: "로드된 두 번째 문장", page: 20)
        ]

        let mockBookStory = BookStory(
            _id: "story123",
            userId: mockUser,
            bookId: mockBook,
            quotes: mockQuotes,
            content: "로드된 느낀점",
            storyImageURLs: nil,
            isPublic: false,
            createdAt: "2023-01-01",
            updatedAt: "2023-01-01",
            keywords: ["키워드1", "키워드2"],
            themeIds: ["theme1", "theme2"]
        )

        // When: loadFromBookStory 호출
        viewModel.loadFromBookStory(mockBookStory)

        // Then: 모든 필드가 로드된 데이터로 업데이트됨
        XCTAssertEqual(viewModel.keywords, ["키워드1", "키워드2"], "keywords가 로드되어야 함")
        XCTAssertEqual(viewModel.quotes.count, 2, "2개의 quotes가 로드되어야 함")
        XCTAssertEqual(viewModel.quotes[0].quote, "로드된 첫 문장")
        XCTAssertEqual(viewModel.quotes[0].page, 10)
        XCTAssertEqual(viewModel.quotes[1].quote, "로드된 두 번째 문장")
        XCTAssertEqual(viewModel.quotes[1].page, 20)
        XCTAssertEqual(viewModel.content, "로드된 느낀점", "content가 로드되어야 함")
        XCTAssertFalse(viewModel.isPublic, "isPublic이 false로 로드되어야 함")
        XCTAssertEqual(viewModel.themeIds, ["theme1", "theme2"], "themeIds가 로드되어야 함")
    }

    /// 테스트 32: loadFromBookStory - quotes가 비어있을 때 빈 Quote 생성
    func testLoadFromBookStory_WhenQuotesEmpty_CreatesEmptyQuote() {
        // Given: quotes가 비어있는 BookStory
        let mockUser = User(
            _id: "user123",
            name: "테스트유저",
            email: "test@example.com",
            profileImage: nil,
            createdAt: "2023-01-01",
            isPremium: false,
            premiumExpiresAt: nil
        )

        let mockBook = Book(
            _id: "book123",
            title: "테스트 책",
            author: "저자",
            bookImageURL: nil,
            createdAt: "2023-01-01"
        )

        let mockBookStory = BookStory(
            _id: "story123",
            userId: mockUser,
            bookId: mockBook,
            quotes: [],  // 빈 배열
            content: nil,
            storyImageURLs: nil,
            isPublic: true,
            createdAt: "2023-01-01",
            updatedAt: "2023-01-01",
            keywords: nil,
            themeIds: nil
        )

        // When: loadFromBookStory 호출
        viewModel.loadFromBookStory(mockBookStory)

        // Then: 1개의 빈 Quote가 생성됨
        XCTAssertEqual(viewModel.quotes.count, 1, "빈 quotes 로드 시 1개의 빈 Quote가 생성되어야 함")
        XCTAssertEqual(viewModel.quotes[0].quote, "", "생성된 Quote는 빈 문자열이어야 함")
    }

    /// 테스트 33: removeImage - 이미지 삭제
    func testRemoveImage_Success() {
        // Given: 3개의 이미지 존재
        viewModel.selectedImages = [UIImage(), UIImage(), UIImage()]

        // When: 인덱스 1의 이미지 삭제
        viewModel.removeImage(at: 1)

        // Then: 이미지가 1개 삭제되어 2개만 남음
        XCTAssertEqual(viewModel.selectedImages.count, 2, "이미지가 1개 삭제되어 2개가 남아야 함")
    }

    /// 테스트 34: removeImage - 잘못된 인덱스 (안전성 테스트)
    func testRemoveImage_InvalidIndex_NoEffect() {
        // Given: 2개의 이미지 존재
        viewModel.selectedImages = [UIImage(), UIImage()]

        // When: 잘못된 인덱스로 삭제 시도
        viewModel.removeImage(at: 5)

        // Then: 아무 변화 없음
        XCTAssertEqual(viewModel.selectedImages.count, 2, "잘못된 인덱스는 무시되어야 함")
    }
}
