//
//  StoryFormViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import SwiftUI

final class StoryFormViewModel: ObservableObject, LoadingViewModel {
    
    // MARK: - LoadingViewModel Protocol
    @Published var isLoading: Bool = false
    @Published var loadingMessage: String?
    
    // MARK: - OCR Manager 직접 생성
    private let ocrUsageManager = OCRUsageManager()
    
    // MARK: - 모든 페이지에서 입력 가능
    /// 키워드 입력
    @Published var keywords: [String] = []
    @Published var inlineKeywordInput: String = ""
    @Published var inlineKeywordFeedback: String? = nil

    /// 공백 키워드를 입력 시도하거나, 키워드 개수가 10개를 초과하거나 중복된 키워드가 있을 때 경고표시
    @Published var isShowingDuplicateWarning = false
    @Published var feedbackMessage: String? = nil
    
    // MARK: - PAGE 1에서 입력 가능
    /// 문장 입력
    @Published var quotes = [Quote(id: UUID(), quote: "", page: nil)]
    
    /// true: 캐러셀(카드 디자인), false: (목록 디자인)
    @Published var isCarouselView: Bool = true
    
    @Published var currentQuoteText: String = ""
    @Published var currentQuotePage: String = ""
    
    // MARK: - PAGE 2에서 입력 가능 (페이지 2는 선택 필드)
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
    
    // MARK: - OCR 관련 상태
    @Published var showingOCRActionSheet = false
    @Published var extractedOCRText = ""
    @Published var showingOCRPreview = false
    @Published var selectedOCRImage: UIImage?
    @Published var ocrTargetQuoteIndex: Int = 0
    
    // OCR 전용 시트 상태 (기존 이미지 피커와 분리)
    @Published var showingOCRCamera = false
    @Published var showingOCRGallery = false
    
    // 글자수 제한 상수
    let keywordMaxLength = 8
    let quoteMaxLength = 500
    let contentMaxLength = 1000
    
    // placeholder
    let quotePlaceholder: String = "간직하고 싶은 문장을 기록해보세요."
    let contentPlaceholder: String = "문장을 읽고 떠오른 생각을 기록해보세요."
    
    // MARK: - Computed Properties
    
    var isQuotesFilled: Bool {
        return quotes.contains { !$0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    // MARK: - OCR Methods
    
    /// OCR 사용 가능 여부 확인
    func canUseOCR() -> Bool {
        return ocrUsageManager.canUseOCR(isPremiumUser: checkPremiumStatus())
    }
    
    /// OCR 프로세스 시작
    func startOCRProcess(with image: UIImage, targetIndex: Int) {
        // 사용 횟수 체크
        guard canUseOCR() else {
            showOCRLimitAlert()
            return
        }
        
        // 타겟 인덱스 저장
        ocrTargetQuoteIndex = targetIndex
        selectedOCRImage = image
        
        // 로딩 시작
        isLoading = true
        loadingMessage = "텍스트를 추출하고 있습니다..."
        
        // OCR 처리
        image.extractText { [weak self] result in
            DispatchQueue.main.async {
                self?.handleOCRResult(result)
            }
        }
    }
    
    /// OCR 결과 처리
    private func handleOCRResult(_ result: String?) {
        // 로딩 종료
        isLoading = false
        loadingMessage = nil
        
        guard let extractedText = result, !extractedText.isEmpty else {
            showOCRErrorAlert()
            return
        }
        
        // 사용 횟수 증가
        ocrUsageManager.incrementUsage()
        
        // 추출된 텍스트 저장 및 미리보기 표시
        extractedOCRText = extractedText
        showingOCRPreview = true
        
        print("OCR 성공 - 추출된 텍스트: \(extractedText.prefix(50))...")
    }
    
    func getTodayUsageCount() {
        ocrUsageManager.getTodayUsageCount()
    }
    
    /// OCR 텍스트를 현재 Quote에 적용
    func applyOCRTextToQuote(_ text: String) {
        guard ocrTargetQuoteIndex < quotes.count else {
            print("OCR 적용 실패: 잘못된 인덱스 \(ocrTargetQuoteIndex)")
            return
        }
        
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let truncatedText = String(cleanedText.prefix(quoteMaxLength))
        
        // 기존 텍스트와 합치기 또는 교체
        if quotes[ocrTargetQuoteIndex].quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // 빈 Quote면 교체
            quotes[ocrTargetQuoteIndex].quote = truncatedText
        } else {
            // 기존 텍스트가 있으면 뒤에 추가
            let currentText = quotes[ocrTargetQuoteIndex].quote
            let combinedText = "\(currentText)\n\(truncatedText)"
            quotes[ocrTargetQuoteIndex].quote = String(combinedText.prefix(quoteMaxLength))
        }
        
        print("✅ OCR 텍스트 적용 완료 - 인덱스: \(ocrTargetQuoteIndex)")
        
        // 상태 초기화
        resetOCRState()
    }
    
    /// OCR 취소
    func cancelOCR() {
        resetOCRState()
    }
    
    /// OCR 상태 초기화
    private func resetOCRState() {
        extractedOCRText = ""
        selectedOCRImage = nil
        showingOCRPreview = false
        showingOCRCamera = false
        showingOCRGallery = false
        ocrTargetQuoteIndex = 0
    }
    
    /// OCR 사용 제한 알림
    func showOCRLimitAlert() {
        let remainingCount = ocrUsageManager.getRemainingFreeUsage()
        let maxCount = ocrUsageManager.getMaxFreeUsage()
        
        if remainingCount > 0 {
            alertMessage = "오늘 OCR 무료 사용 횟수: \(maxCount - remainingCount)/\(maxCount)회"
        } else {
            alertMessage = """
            오늘 OCR 무료 사용 횟수(\(maxCount)회)를 모두 사용했습니다.
            """
        }
        
        showAlert = true
    }
    
    /// OCR 에러 알림
    private func showOCRErrorAlert() {
        alertMessage = """
        텍스트를 인식할 수 없습니다.
        
        • 텍스트가 선명한 이미지를 사용해주세요
        • 조명이 밝은 곳에서 촬영해주세요
        • 텍스트가 잘 보이도록 각도를 조정해주세요
        """
        showAlert = true
    }
    
    /// 프리미엄 상태 확인 (향후 인앱결제 연동)
    private func checkPremiumStatus() -> Bool {
        // TODO: 인앱결제 상태 확인 로직 구현
        return false  // 현재는 모든 사용자가 무료
    }
    
    
    /// 카메라 열기
    func openCamera() {
        checkCameraPermission()
    }
    
    /// 사진 라이브러리 열기
    func openPhotoLibrary() {
        checkGalleryPermission()
    }
    
    func checkCameraPermission() {
        PermissionsManager.shared.checkCameraAuthorization { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.sourceType = .camera
                    self?.showingCamera = true
                } else {
                    self?.alertType = .authorized
                    self?.showCameraPermissionAlert()
                }
            }
        }
    }
    
    func checkGalleryPermission() {
        PermissionsManager.shared.checkPhotosAuthorization { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.sourceType = .photoLibrary
                    self?.showingGallery = true
                } else {
                    self?.alertType = .authorized
                    self?.showGalleryPermissionAlert()
                }
            }
        }
    }
    
    private func showCameraPermissionAlert() {
        alertMessage = "북스토리에 이미지를 업로드하려면 카메라 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
        showAlert = true
    }
    
    private func showGalleryPermissionAlert() {
        alertMessage = "북스토리에 이미지를 업로드하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
        showAlert = true
    }
    
    // MARK: - Quote Methods
    
    func pageBinding(for quoteId: UUID) -> Binding<String> {
        Binding<String>(
            get: {
                self.quotes.first { $0.id == quoteId }?.page?.description ?? ""
            },
            set: { newValue in
                if let index = self.quotes.firstIndex(where: { $0.id == quoteId }) {
                    let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.quotes[index].page = trimmedValue.isEmpty ? nil : Int(trimmedValue)
                }
            }
        )
    }
    
    func addQuote(at index: Int? = nil) {
        let newQuote = Quote(id: UUID(), quote: "", page: nil)
        if let index = index {
            quotes.insert(newQuote, at: min(index + 1, quotes.count))
        } else {
            quotes.append(newQuote)
        }
    }
    
    func removeQuote(at index: Int) {
        guard quotes.count > 1, index < quotes.count else { return }
        quotes.remove(at: index)
    }
    
    func addCurrentQuote() {
        let trimmedQuote = currentQuoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuote.isEmpty else { return }
        
        let page = currentQuotePage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                   nil : Int(currentQuotePage.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let newQuote = Quote(id: UUID(), quote: trimmedQuote, page: page)
        quotes.append(newQuote)
        
        currentQuoteText = ""
        currentQuotePage = ""
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
    
    // MARK: - Form Management
    
    func resetForm() {
        keywords = []
        quotes = [Quote(id: UUID(), quote: "", page: nil)]
        content = ""
        selectedImages = []
        isPublic = true
        themeIds = []
        inlineKeywordInput = ""
        feedbackMessage = nil
        
        // OCR 상태도 리셋
        resetOCRState()
    }
    
    // image method
    
    func removeImage(at index: Int) {
        guard index >= 0 && index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    // MARK: - Data Loading (for Update)
    
    func loadFromBookStory(_ story: BookStory) {
        keywords = story.keywords ?? []
        quotes = story.quotes.isEmpty ? [Quote(id: UUID(), quote: "", page: nil)] : story.quotes
        content = story.content ?? ""
        isPublic = story.isPublic
        themeIds = story.themeIds ?? []
        
        loadImagesFromLoadedStory(story)
    }
    
    private func loadImagesFromLoadedStory(_ story: BookStory) {
        guard let imagesURLs = story.storyImageURLs, !imagesURLs.isEmpty else {
            selectedImages = [] // 이미지 빈배열이거나 없을 때
            return
        }
        
        var loadedImages: [UIImage] = []
        
        // 여러 비동기 작업을 그룹으로 관리
        let group = DispatchGroup()
        
        for urlString in imagesURLs {
            // 그룹에 작업 시작을 알림 (counter + 1)
            group.enter()
            
            guard let url = URL(string: urlString) else {
                // URL이 유효하지 않으면 그룹에서 나가기 (카운터 -1)
                group.leave()
                continue    // 다음 URL로 건너띔
            }
            
            // URLSession으로 비동기 네트워크 요청 (이미 내부적으로 비동기로 구현되어 있음)
            URLSession.shared.dataTask(with: url) { data, response, error in
                // defer - 이 클로저가 끝날 때 반드시 실행됨
                defer { group.leave() } // 성공과 실패 관계없이 카운터 -1
                
                // 데이터 유효성 검사 및 이미지 변환로직
                guard let data = data,
                      let image = UIImage(data: data) else {
                    print("북스토리 이미지를 불러오지 못했습니다. \(urlString)")
                    return  // 실패 시 defer 가 group.leave() 호출
                }
                
                // 메인 스레드에서 UI 관련 작업 수행
                DispatchQueue.main.async {
                    loadedImages.append(image)
                }
            }.resume()  // 실제 네트워크 요청 시작.
        }
        
        // 모든 urls 작업이 완료되면 비동기 작업이 완료되었다고 알려줌 (카운터가 0이되면 notify됨)
        group.notify(queue: .main) {
            self.selectedImages = loadedImages
        }
    }
    
    // MARK: - OCR 디버그 메서드 (개발용)
    
    #if DEBUG
    func debugResetOCRUsage() {
        ocrUsageManager.debugResetUsage()
    }
    
    func debugSetOCRUsage(_ count: Int) {
        ocrUsageManager.debugSetUsage(count)
    }
    #endif
}

// MARK: - StoryFormViewModel Extension
extension StoryFormViewModel {
    /// 현재 폼 데이터가 임시저장할 가치가 있는지 확인
    var hasValueForDraft: Bool {
        return !keywords.isEmpty ||
               quotes.contains { !$0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ||
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
               !selectedImages.isEmpty
    }
}
