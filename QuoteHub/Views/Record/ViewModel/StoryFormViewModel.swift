//
//  StoryFormViewModel.swift
//  QuoteHub
//
//  Created by AI Assistant on 6/9/25.
//

import SwiftUI

class StoryFormViewModel: ObservableObject {
    // 키워드 입력
    @Published var keywords: [String] = []
    
    // 문장 입력
    @Published var quotes: [Quote] = []
    @Published var currentQuoteText: String = ""
    @Published var currentQuotePage: String = ""
    
    // 컨텐츠 입력
    @Published var content: String = ""
    
    // 이미지 피커
    @Published var showingImagePicker = false
    @Published var showingCamera = false
    @Published var showingGallery = false
    @Published var selectedImages: [UIImage] = []
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // 키워드 텍스트 인풋 관련
    @Published var currentKeywordInput: String = ""
    /// 공백 키워드를 입력 시도하거나, 키워드 개수가 5개를 초과하거나 중복된 키워드가 있을 때 경고표시
    @Published var isShowingDuplicateWarning = false
    @Published var feedbackMessage: String? = nil
    
    // 공개 여부 및 테마
    @Published var isPublic: Bool = true
    @Published var themeIds: [String] = []
    
    // 알림 관련
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var alertType: PhotoPickerAlertType = .authorized
    
    // 글자수 제한 상수
    let keywordMaxLength = 8
    let quoteMaxLength = 500
    let contentMaxLength = 1000
    
    // placeholder
    let quotePlaceholder: String = "간직하고 싶은 문장을 기록해보세요."
    let contentPlaceholder: String = "문장을 읽고 떠오른 생각을 기록해보세요."
    
    // MARK: - Computed Properties
    
    /// 모든 입력 필드가 비어있는지 확인
    var isEmpty: Bool {
        keywords.isEmpty &&
        quotes.isEmpty &&
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedImages.isEmpty
    }
    
    /// 북스토리 생성 요건 충족 확인
    var isQuotesFilled: Bool {
        !quotes.isEmpty
    }
    
    // MARK: - Methods
    
    func addKeyword() {
        // 키워드 입력란의 앞뒤 공백과 줄바꿈 문자를 제거
        let trimmedKeyword = currentKeywordInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 공백 키워드를 입력 시도하거나, 키워드 개수가 5개를 초과하거나 중복된 키워드가 있을 때 경고표시
        if trimmedKeyword.isEmpty || keywords.count >= 5 || keywords.contains(trimmedKeyword) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isShowingDuplicateWarning = true
            }
            // 3초 후 경고 숨김
            // 화면을 빠르게 뒤로 나가면 클로저에서 강하게 캡쳐하여 순환참조가 발생하므로, 약하게 캡쳐
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else { return }
                withAnimation {
                    self.isShowingDuplicateWarning = false
                }
            }
        } else {    // 유효한 키워드인 경우
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                keywords.append(trimmedKeyword)
                currentKeywordInput = ""
            }
        }
    }
    
    func removeKeyword(_ keyword: String) {
        if let index = keywords.firstIndex(of: keyword) {
            keywords.remove(at: index)
        }
    }
    
    func addQuote() {
        let trimmedQuote = currentQuoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuote.isEmpty else { return }
        
        let pageNumber = Int(currentQuotePage.trimmingCharacters(in: .whitespacesAndNewlines))
        let newQuote = Quote(quote: trimmedQuote, page: pageNumber)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            quotes.append(newQuote)
            currentQuoteText = ""
            currentQuotePage = ""
        }
    }
    
    func removeQuote(at index: Int) {
        quotes.remove(at: index)
    }
    
    func updateFeedbackMessage() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if quotes.isEmpty {
                feedbackMessage = "인용문을 최소 하나 입력해주세요."
            } else if quotes.contains(where: { $0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                feedbackMessage = "빈 문장이 있습니다. 내용을 입력해주세요."
            } else {
                feedbackMessage = nil
            }
        }
    }
    
    func resetForm() {
        keywords = []
        quotes = []
        currentQuoteText = ""
        currentQuotePage = ""
        content = ""
        selectedImages = []
        isPublic = true
        themeIds = []
        currentKeywordInput = ""
        feedbackMessage = nil
    }
    
    // MARK: - Data Loading (for Update)
    
    func loadFromBookStory(_ story: BookStory) {
        keywords = story.keywords ?? []
        quotes = story.quotes
        content = story.content ?? ""
        isPublic = story.isPublic
        themeIds = story.themeIds ?? []
        
        // 이미지 URL들을 UIImage로 변환하는 로직이 필요하다면 여기에 추가
        // selectedImages = ... (서버에서 이미지를 다운로드하는 로직)
    }
}
