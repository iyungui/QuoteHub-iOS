//
//  StoryFormViewModel.swift
//  QuoteHub
//
//  Created by AI Assistant on 6/9/25.
//

import SwiftUI

@Observable
class StoryFormViewModel {
    // 키워드 입력
    var keywords: [String] = []
    
    // 인용구 입력
    var quotes: [Quote] = []
    var currentQuoteText: String = ""
    var currentQuotePage: String = ""
    
    // 컨텐츠 입력
    var content: String = ""
    
    // 텍스트 인풋 관련
    var currentInput: String = ""
    var isShowingDuplicateWarning = false
    var feedbackMessage: String? = nil
    
    // 이미지 피커
    var showingImagePicker = false
    var showingCamera = false
    var showingGallery = false
    var selectedImages: [UIImage] = []
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // 공개 여부 및 테마
    var isPublic: Bool = true
    var themeIds: [String] = []
    
    // 알림 관련
    var showAlert: Bool = false
    var alertMessage: String = ""
    var alertType: PhotoPickerAlertType = .authorized
    
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
        let trimmedKeyword = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedKeyword.isEmpty && keywords.count < 5 {
            if keywords.contains(trimmedKeyword) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isShowingDuplicateWarning = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    guard let self = self else { return }
                    withAnimation {
                        self.isShowingDuplicateWarning = false
                    }
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    keywords.append(trimmedKeyword)
                    currentInput = ""
                }
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
                feedbackMessage = "빈 인용구가 있습니다. 내용을 입력해주세요."
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
        currentInput = ""
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
