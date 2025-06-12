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
    @Published var currentKeywordInput: String = ""
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
    
    func addKeyword() {
        // 키워드 입력란의 앞뒤 공백과 줄바꿈 문자를 제거
        let trimmedKeyword = currentKeywordInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 공백 키워드를 입력 시도하거나, 키워드 개수가 10개를 초과하거나 중복된 키워드가 있을 때 경고표시
        if trimmedKeyword.isEmpty || keywords.count >= 10 || keywords.contains(trimmedKeyword) {
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
        currentKeywordInput = ""
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
