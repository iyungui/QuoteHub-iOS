//
//  StoryFormViewModel.swift
//  QuoteHub
//
//  Created by AI Assistant on 6/9/25.
//

import SwiftUI

class StoryFormViewModel: ObservableObject {
    // 모든 페이지에서 입력 가능
    /// 키워드 입력
    @Published var keywords: [String] = []
    @Published var inlineKeywordInput: String = ""
    @Published var inlineKeywordFeedback: String? = nil

    /// 공백 키워드를 입력 시도하거나, 키워드 개수가 10개를 초과하거나 중복된 키워드가 있을 때 경고표시
    @Published var isShowingDuplicateWarning = false
    @Published var feedbackMessage: String? = nil
    
    // PAGE 1에서 입력 가능
    /// 문장 입력
    @Published var quotes = [Quote(id: UUID(), quote: "", page: nil)]
    
    /// true: 캐러셀(카드 디자인), false: (목록 디자인)
    @Published var isCarouselView: Bool = true
    
    @Published var currentQuoteText: String = ""
    @Published var currentQuotePage: String = ""
    
    
    // PAGE 2에서 입력 가능 (페이지 2는 선택 필드)
    /// 느낀점 입력
    @Published var showingContentSheet = false
    @Published var content: String = ""
    
    @Published var showingCamera = false
    @Published var showingGallery = false
    @Published var selectedImages: [UIImage] = []
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
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
        quotes.contains { !$0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    // MARK: - Image Methods
    
    func removeImage(at index: Int) {
        guard index >= 0 && index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    func openPhotoLibrary() {
        sourceType = .photoLibrary
        PermissionsManager.shared.checkPhotosAuthorization { [weak self] authorized in
            DispatchQueue.main.async {
                if authorized {
                    self?.showingGallery = true
                } else {
                    self?.showPermissionAlert(for: .photoLibrary)
                }
            }
        }
    }
    
    func openCamera() {
        sourceType = .camera
        PermissionsManager.shared.checkCameraAuthorization { [weak self] authorized in
            DispatchQueue.main.async {
                if authorized {
                    self?.showingCamera = true
                } else {
                    self?.showPermissionAlert(for: .camera)
                }
            }
        }
    }
    
    private func showPermissionAlert(for sourceType: UIImagePickerController.SourceType) {
        alertType = .authorized
        alertMessage = sourceType == .camera ?
            "북스토리에 이미지를 업로드하려면 카메라 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요." :
            "북스토리에 이미지를 업로드하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
        showAlert = true
    }
    
    // MARK: - Keyword Methods
    
    /// 인라인 키워드 입력 처리 ("#키워드" 형태)
    func processInlineKeywordInput(_ newValue: String) {
        // 띄어쓰기나 줄바꿈 감지 시 키워드 추가
        if newValue.contains(" ") || newValue.contains("\n") {
            addInlineKeyword(from: newValue)
        }
    }

    /// 인라인 입력에서 키워드 추출 및 추가
    private func addInlineKeyword(from input: String) {
        let cleanInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // "#" 제거하고 키워드만 추출
        let keyword = cleanInput.replacingOccurrences(of: "#", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 빈 키워드는 조용히 무시
        guard !keyword.isEmpty else {
            inlineKeywordInput = ""
            return
        }
        
        // 유효성 검사 및 피드백 처리
        if isValidInlineKeyword(keyword) {
            keywords.append(keyword)
        } else {
            showInlineKeywordFeedback(for: keyword)
        }
        
        // 입력 필드 리셋
        inlineKeywordInput = ""
    }

    /// 키워드 유효성 검사 (인라인용)
    private func isValidInlineKeyword(_ keyword: String) -> Bool {
        return keyword.count <= keywordMaxLength &&
               !keywords.contains(keyword) &&
               keywords.count < 10
    }

    /// 피드백 메시지 표시
    private func showInlineKeywordFeedback(for keyword: String) {
        let message: String
        
        if keyword.count > keywordMaxLength {
            message = "키워드는 8자 이내로 입력해주세요"
        } else if keywords.contains(keyword) {
            message = "이미 추가된 키워드입니다"
        } else if keywords.count >= 10 {
            message = "키워드는 최대 10개까지 추가할 수 있습니다"
        } else {
            return // 예상치 못한 경우, 피드백 없음
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            inlineKeywordFeedback = message
        }
        
        // 3초 후 피드백 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            withAnimation {
                self.inlineKeywordFeedback = nil
            }
        }
    }

    /// 키워드 제거 (기존과 동일하지만 명시적)
    func removeInlineKeyword(_ keyword: String) {
        keywords.removeAll { $0 == keyword }
    }

    // MARK: - Quote Methods
    
    /// quote 캐러셀 뷰에서 사용 (빈 quote 페이지 생성)
    func addQuote(at index: Int? = nil) {
        let newQuote = Quote(id: UUID(), quote: "", page: nil)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if let index = index {
                // 현재 인덱스 바로 뒤에 추가
                let insertIndex = min(index + 1, quotes.count)
                quotes.insert(newQuote, at: insertIndex)
            } else {
                // 인덱스가 주어지지 않으면 맨 뒤 페이지에 quote 추가
                quotes.append(newQuote)
            }
        }
    }
    
    /// quote 리스트 뷰에서 사용
    func addCurrentQuote() {
        let trimmedText = currentQuoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let page = currentQuotePage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
        nil : Int(currentQuotePage.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let newQuote = Quote(id: UUID(), quote: trimmedText, page: page)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            // 빈 quote가 있다면 대체, 없다면 추가
            if let emptyIndex = quotes.firstIndex(where: {
                $0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }) {
                quotes[emptyIndex] = newQuote
            } else {
                quotes.append(newQuote)
            }
        }
        clearQuoteInputField()
    }
    
    private func clearQuoteInputField() {
        // 입력창 초기화
        currentQuoteText = ""
        currentQuotePage = ""
    }
    
    func removeQuote(at index: Int) {
        // 인덱스 범위 유효한지 확인
        guard index >= 0 && index < quotes.count else { return }
        
        quotes.remove(at: index)
    }
    
    // 페이지 번호를 String으로 바인딩하기 위한 헬퍼 메서드
    func pageBinding(for quoteId: UUID) -> Binding<String> {
        Binding(
            get: {
                guard let index = self.quotes.firstIndex(where: { $0.id == quoteId }) else {
                    return ""
                }
                return self.quotes[index].page?.description ?? ""
            },
            set: { newValue in
                guard let index = self.quotes.firstIndex(where: { $0.id == quoteId }) else {
                    return
                }
                let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                self.quotes[index].page = trimmedValue.isEmpty ? nil : Int(trimmedValue)
            }
        )
    }
    
    func updateFeedbackMessage() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if quotes.isEmpty {
                feedbackMessage = "문장을 최소 하나 입력해주세요."
            } else if quotes.contains(where: { $0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                feedbackMessage = "빈 문장이 있습니다. 내용을 입력해주세요."
            } else {
                feedbackMessage = nil
            }
        }
    }
    
    // MARK: - Form Management
    
    func resetForm() {
        keywords = []
        quotes = [Quote(quote: "", page: nil)]
        content = ""
        selectedImages = []
        isPublic = true
        themeIds = []
        inlineKeywordInput = ""
        feedbackMessage = nil
    }
    
    // MARK: - Data Loading (for Update)
    
    func loadFromBookStory(_ story: BookStory) {
        keywords = story.keywords ?? []
        quotes = story.quotes.isEmpty ? [Quote(quote: "", page: nil)] : story.quotes
        content = story.content ?? ""
        isPublic = story.isPublic
        themeIds = story.themeIds ?? []
        
        // 이미지 URL들을 UIImage로 변환하는 로직이 필요하다면 여기에 추가
        // selectedImages = ... (서버에서 이미지를 다운로드하는 로직)
    }
}
