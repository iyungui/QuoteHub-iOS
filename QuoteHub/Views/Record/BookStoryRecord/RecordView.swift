//
//  RecordView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

/// 북스토리 기록 3: 북스토리 기록 뷰
struct RecordView: View {
    
    // MARK: - PROPERTIES
    
    let book: Book
    let preloadedDraft: DraftStory? // 이어서 작성하기 선택한 경우 nil이 아님
    let shouldClearDraft: Bool  // 새로 작성하기 선택한 경우

    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var draftManager: DraftManager?
    
    // 임시저장 관련
    @State private var shouldLoadDraft: Bool = true
    @State private var showDraftAlert: Bool = false
    @State private var currentDraft: DraftStory?
    @State private var saveDraftSuccessPrompt: Bool = false
    
    // MARK: - INIT
    
    init(book: Book, preloadedDraft: DraftStory? = nil, shouldClearDraft: Bool = false) {
        self.book = book
        self.preloadedDraft = preloadedDraft
        self.shouldClearDraft = shouldClearDraft
    }
        
    // 키워드 입력
    @State private var keywords: [String] = []
    // 인용구 입력
    @State private var quote: String = ""
    // 컨텐츠 (느낀점, 생각) 입력
    @State private var content: String = ""

    // 텍스트 인풋 관련
    @State private var currentInput: String = ""
    @State private var isShowingDuplicateWarning = false
    @State private var feedbackMessage: String? = nil

    // 글자수 제한 상수
    private let keywordMaxLength = 8
    private let quoteMaxLength = 500
    private let contentMaxLength = 1000

    // placeholder
    let quotePlaceholder: String = "간직하고 싶은 문장을 기록해보세요."
    let contentPlaceholder: String = "문장을 읽고 떠오른 생각을 기록해보세요."

    // 이미지 피커
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingGallery = false
    @State private var selectedImages: [UIImage] = []
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // 북스토리 공개 여부 토글
    @State private var isPublic: Bool = true
    
    // 어느 테마에 북스토리 올릴 것인지
    @State private var themeIds: [String] = []
    
    // focus state
    enum Field: Hashable {
        case keywords
        case quote
        case content
    }
    @FocusState private var focusField: Field?
    
    @State private var alertType: PhotoPickerAlertType = .authorized
    
    /// 모든 입력 필드가 비어있는지 확인. 임시(자동) 저장 전에 사용
    private var isEmpty: Bool {
        keywords.isEmpty &&
        quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedImages.isEmpty
    }
    
    /// 북스토리 생성 호출 요건 충족 확인
    private var isFormValid: Bool {
        !quote.isEmpty && !content.isEmpty && !keywords.isEmpty
    }

    // MARK: - BODY
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 24) {
                    // 책 정보 카드
                    bookInfoCard
                    
                    // 키워드 입력 카드
                    keywordCard
                    
                    // 인용구 입력 카드
                    quoteCard
                    
                    // 생각 입력 카드
                    thoughtCard
                    
                    // 이미지 추가 카드
                    StoryImagesView(selectedImages: $selectedImages, showingImagePicker: $showingImagePicker)
                    
                    // 설정 카드들
                    VStack(spacing: 16) {
                        themeSelectionCard
                        privacyToggleCard
                    }
                    
                    
                    // 하단 여백
                    spacer(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("북스토리 기록")
        .toolbar {
            // 임시저장 버튼
            ToolbarItem(placement: .topBarTrailing) {
                draftSaveButton
            }
            // 등록 버튼
            ToolbarItem(placement: .primaryAction) {
                submitButton
            }
            // 피드백 메시지
            ToolbarItem(placement: .bottomBar) {
                // 북스토리 생성가능해지면(isFormValid) 자동으로 피드백메시지 사라지도록
                // 그리고 임시저장 기능 메시지 활성화 시에도 피드백메시지 보이도록
                if let message = feedbackMessage, (!isFormValid || saveDraftSuccessPrompt) {
                    feedbackView(message: message)
                }
            }
        }
        .progressOverlay(viewModel: storiesViewModel, animationName: "progressLottie", opacity: true)
        .onAppear {
            setupDraftManager()
            handlePreloadedDraft()
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
        .onChange(of: keywords) { _, _ in triggerAutoSave() }
        .onChange(of: quote) { _, _ in triggerAutoSave() }
        .onChange(of: content) { _, _ in triggerAutoSave() }
        .onChange(of: selectedImages) { _, _ in triggerAutoSave() }
        .onChange(of: isPublic) { _, _ in triggerAutoSave() }
        .onChange(of: themeIds) { _, _ in triggerAutoSave() }
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImages: self.$selectedImages, sourceType: self.sourceType)
                .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $showingGallery) {
            MultipleImagePicker(selectedImages: self.$selectedImages, selectionLimit: max(0, 10 - selectedImages.count))
                .ignoresSafeArea(.all)
        }
        .actionSheet(isPresented: $showingImagePicker) {
            ActionSheet(title: Text("이미지 선택"), message: nil, buttons: [
                .default(Text("카메라")) {
                    self.sourceType = .camera
                    PermissionsManager.shared.checkCameraAuthorization { authorized in
                        if authorized {
                            self.showingCamera = true
                        } else {
                            self.alertType = .authorized
                            self.alertMessage = "북스토리에 이미지를 업로드하려면 카메라 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
                            self.showAlert = true
                        }
                    }
                },
                .default(Text("사진 라이브러리")) {
                    self.sourceType = .photoLibrary
                    PermissionsManager.shared.checkPhotosAuthorization { authorized in
                        if authorized {
                            self.showingGallery = true
                        } else {
                            self.alertType = .authorized
                            self.alertMessage = "북스토리에 이미지를 업로드하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
                            self.showAlert = true
                        }
                    }
                },
                .cancel()
            ])
        }
        .alert(isPresented: $showAlert) {
            switch alertType {
            case .authorized:
                return Alert(title: Text("권한 필요"),
                             message: Text(alertMessage),
                             primaryButton: .default(Text("설정으로 이동"), action: {
                                 if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                                    UIApplication.shared.canOpenURL(settingsUrl) {
                                     UIApplication.shared.open(settingsUrl)
                                 }
                             }),
                             secondaryButton: .cancel()
                )
            case .make:
                return Alert(
                    title: Text("알림"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("확인"), action: {
                        if alertMessage.contains("성공적으로") {
                            draftManager?.clearDraft()
                            dismiss()
                        }
                    })
                )
            }
        }
    }
    
    // MARK: - Draft Management
    
    private func setupDraftManager() {
        draftManager = DraftManager(modelContext: modelContext)
    }
    
    private func handlePreloadedDraft() {
        if shouldClearDraft {
            // 새로 작성하기 선택한 경우
            draftManager?.clearDraft()
            currentDraft = draftManager?.createDraftFromBook(book)
            resetForm()
        } else if let preloadedDraft = preloadedDraft {
            // 이어서 작성하기 선택한 경우
            currentDraft = preloadedDraft
            loadDraftData(preloadedDraft)
        } else {
            // 일반적인 경우 (다른 뷰에서 직접 접근)
            checkForExistingDraft()
        }
        shouldLoadDraft = false
    }
    
    private func checkForExistingDraft() {
        guard shouldLoadDraft, let draftManager = draftManager else { return }
        
        if draftManager.hasDraft() {
            currentDraft = draftManager.loadDraft()
            
            // 현재 책과 같은 책의 임시저장인 경우에만 로드
            if let draft = currentDraft, draft.bookId == book.id {
                loadDraftData(draft)
            } else {
                // 다른 책의 임시저장이 있으면 새로 시작
                createNewDraft()
            }
        }
//        shouldLoadDraft = false
    }
    
    private func createNewDraft() {
        draftManager?.clearDraft()
        currentDraft = draftManager?.createDraftFromBook(book)
        resetForm()
    }
    
    /// 임시저장 데이터 가져오기
    private func loadDraftData(_ draft: DraftStory) {
        keywords = draft.keywords
        quote = draft.quote
        content = draft.content
        isPublic = draft.isPublic
        themeIds = draft.themeIds
        
        // 이미지 데이터를 UIImage로 변환
        if !draft.imageData.isEmpty {
            selectedImages = draftManager?.convertDataToImages(draft.imageData) ?? []
        }
        
        print("임시저장 데이터 로드 완료 - 키워드: \(keywords.count), 이미지: \(selectedImages.count)")
    }
    
    /// 데이터 초기화
    private func resetForm() {
        keywords = []
        quote = ""
        content = ""
        selectedImages = []
        isPublic = true
        themeIds = []
        currentInput = ""
    }
    
    /// 자동 저장 함수
    private func triggerAutoSave() {
        print(#fileID, #function, #line, "- ")
        guard !isEmpty else { return }
        
        draftManager?.startAutoSave(
            bookId: book.id,
            bookTitle: book.title,
            bookAuthor: book.author.joined(separator: ", "),
            bookImageURL: book.bookImageURL,
            keywords: keywords,
            quote: quote,
            content: content,
            isPublic: isPublic,
            themeIds: themeIds,
            images: selectedImages
        )
    }
    
    /// app life cycle에 따라 즉시 저장 로직 실행
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            // 백그라운드 진입시 즉시 저장
            if !isEmpty {
                saveDraftImmediately()
            }
        case .active:
            break
        @unknown default:
            break
        }
    }
    
    /// 수동으로 임시저장 버튼 누르거나, 앱이 백그라운드로 들어갈 때 실행됨
    private func saveDraftImmediately() {
        draftManager?.stopAutoSave()
        draftManager?.saveDraft(
            bookId: book.id,
            bookTitle: book.title,
            bookAuthor: book.author.joined(separator: ", "),
            bookImageURL: book.bookImageURL,
            keywords: keywords,
            quote: quote,
            content: content,
            isPublic: isPublic,
            themeIds: themeIds,
            images: selectedImages
        )
    }
    
    // MARK: - UI Components
    
    private var draftSaveButton: some View {
        Button(action: {
            saveDraftImmediately()
            showPrompt()
        }) {
            Image(systemName: "square.and.arrow.down")
                .fontWeight(.medium)
                .foregroundColor(isEmpty ? .gray : .appAccent)
                .offset(y: -2)
        }
        .opacity(isEmpty ? 0.5 : 1.0)
        .disabled(isEmpty)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.softBeige.opacity(0.3),
                Color.lightPaper.opacity(0.2),
                Color.paperBeige.opacity(0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var submitButton: some View {
        Button(action: submitStory) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(isFormValid ? .appAccent : .gray)
                    .scaleEffect(isFormValid ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFormValid)
                if isFormValid {
                    Text("등록")
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }
    
    private var bookInfoCard: some View {
        VStack(spacing: 16) {
            cardHeader(title: "선택한 책", icon: "book.fill")
            
            HStack(spacing: 16) {
                WebImage(url: URL(string: book.bookImageURL))
                    .placeholder {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.paperBeige.opacity(0.3))
                            .overlay(
                                Image(systemName: "book.closed.fill")
                                    .foregroundColor(.brownLeather.opacity(0.7))
                                    .font(.title2)
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.antiqueGold.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .brownLeather.opacity(0.2), radius: 6, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.scoreDream(.bold, size: .subheadline))
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if !book.author.isEmpty {
                        Text(book.author.joined(separator: ", "))
                            .font(.scoreDream(.medium, size: .footnote))
                            .foregroundColor(.secondaryText)
                            .lineLimit(1)
                    }
                    
                    Text(book.publisher)
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var keywordCard: some View {
        VStack(spacing: 16) {
            cardHeader(title: "키워드", icon: "tag.fill", subtitle: "최대 5개까지 입력 가능")
            
            VStack(spacing: 12) {
                if keywords.count < 5 {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "number")
                                .font(.body)
                                .foregroundColor(.brownLeather.opacity(0.7))
                                .frame(width: 20)
                            
                            TextField("키워드 입력", text: $currentInput)
                                .focused($focusField, equals: .keywords)
                                .submitLabel(.done)
                                .onChange(of: currentInput) { _, newValue in
                                    if newValue.count > keywordMaxLength {
                                        currentInput = String(newValue.prefix(keywordMaxLength))
                                    }
                                }
                                .onSubmit(addKeyword)
                                .font(.scoreDream(.medium, size: .body))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.paperBeige.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusField == .keywords ? Color.brownLeather.opacity(0.5) : Color.clear, lineWidth: 2)
                                )
                        )
                        .animation(.easeInOut(duration: 0.2), value: focusField)
                        
                        // 글자수 표시
                        HStack {
                            Spacer()
                            Text("\(currentInput.count)/\(keywordMaxLength)")
                                .font(.scoreDream(.light, size: .caption2))
                                .foregroundColor(currentInput.count >= keywordMaxLength ? .orange : .secondaryText)
                        }
                    }
                }
                
                if isShowingDuplicateWarning {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("중복된 키워드입니다.")
                            .font(.scoreDream(.medium, size: .caption))
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                }
                
                if !keywords.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(keywords, id: \.self) { keyword in
                                keywordChip(keyword: keyword)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                if keywords.isEmpty {
                    Text("키워드를 입력하고 완료 버튼을 눌러주세요.")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText)
                }
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private func keywordChip(keyword: String) -> some View {
        HStack(spacing: 6) {
            Text("#\(keyword)")
                .font(.scoreDream(.medium, size: .caption))
                .foregroundColor(.white)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    removeKeyword(keyword)
                }
            }) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.brownLeather, .antiqueGold]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .shadow(color: .brownLeather.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var quoteCard: some View {
        VStack(spacing: 16) {
            cardHeader(title: "인용구", icon: "quote.opening", subtitle: "마음에 드는 문장을 기록해보세요")
            
            VStack(spacing: 8) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.paperBeige.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(focusField == .quote ? Color.brownLeather.opacity(0.5) : Color.clear, lineWidth: 2)
                        )
                        .frame(minHeight: 120)
                        .animation(.easeInOut(duration: 0.2), value: focusField)
                    
                    if quote.isEmpty {
                        Text(quotePlaceholder)
                            .font(.scoreDream(.light, size: .body))
                            .foregroundColor(.secondaryText.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $quote)
                        .font(.scoreDream(.regular, size: .body))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.clear)
                        .focused($focusField, equals: .quote)
                        .scrollContentBackground(.hidden)
                        .onChange(of: quote) { _, newValue in
                            if newValue.count > quoteMaxLength {
                                quote = String(newValue.prefix(quoteMaxLength))
                            }
                        }
                }
                
                // 글자수 표시
                HStack {
                    Spacer()
                    Text("\(quote.count)/\(quoteMaxLength)")
                        .font(.scoreDream(.light, size: .caption2))
                        .foregroundColor(quote.count >= quoteMaxLength ? .orange : .secondaryText)
                }
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var thoughtCard: some View {
        VStack(spacing: 16) {
            cardHeader(title: "나의 생각", icon: "brain.head.profile", subtitle: "문장을 읽고 떠오른 생각을 기록해보세요")
            
            VStack(spacing: 8) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.paperBeige.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(focusField == .content ? Color.brownLeather.opacity(0.5) : Color.clear, lineWidth: 2)
                        )
                        .frame(minHeight: 150)
                        .animation(.easeInOut(duration: 0.2), value: focusField)
                    
                    if content.isEmpty {
                        Text(contentPlaceholder)
                            .font(.scoreDream(.light, size: .body))
                            .foregroundColor(.secondaryText.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $content)
                        .font(.scoreDream(.regular, size: .body))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.clear)
                        .focused($focusField, equals: .content)
                        .scrollContentBackground(.hidden)
                        .onChange(of: content) { _, newValue in
                            if newValue.count > contentMaxLength {
                                content = String(newValue.prefix(contentMaxLength))
                            }
                        }
                }
                
                // 글자수 표시
                HStack {
                    Spacer()
                    Text("\(content.count)/\(contentMaxLength)")
                        .font(.scoreDream(.light, size: .caption2))
                        .foregroundColor(content.count >= contentMaxLength ? .orange : .secondaryText)
                }
            }
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var themeSelectionCard: some View {
        VStack(spacing: 16) {
            cardHeader(title: "테마 설정", icon: "folder.fill")
            
            NavigationLink(destination: SetThemeView(selectedThemeIds: $themeIds)) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.brownLeather)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("테마 선택하기")
                            .font(.scoreDream(.medium, size: .body))
                            .foregroundColor(.primaryText)
                        
                        Text(themeIds.isEmpty ? "테마를 선택해주세요" : "\(themeIds.count)개의 테마 선택됨")
                            .font(.scoreDream(.light, size: .caption))
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondaryText.opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.paperBeige.opacity(0.3))
                )
            }
            .buttonStyle(CardButtonStyle())
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
    
    private var privacyToggleCard: some View {
        VStack(spacing: 16) {
            cardHeader(title: "공개 설정", icon: "eye.fill")
            
            HStack {
                Text(isPublic ? "다른 사용자들도\n볼 수 있습니다" : "나만 볼 수 있습니다")
                    .font(.scoreDream(.light, size: isPublic ? .caption2 : .caption))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Toggle("", isOn: $isPublic)
                    .toggleStyle(SwitchToggleStyle())
                    .scaleEffect(0.9)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.paperBeige.opacity(0.3))
            )
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
    
    private func feedbackView(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: saveDraftSuccessPrompt ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(saveDraftSuccessPrompt ? .green : .orange)
                .font(.body)
            
            Text(message)
                .font(.scoreDream(.medium, size: .subheadline))
                .foregroundColor(saveDraftSuccessPrompt ? .green : .orange)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill((saveDraftSuccessPrompt ? Color.green : Color.orange).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke((saveDraftSuccessPrompt ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.asymmetric(insertion: .opacity, removal: .slide))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: feedbackMessage)
    }
    
    // MARK: - Helper Views
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.antiqueGold.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    private func cardHeader(title: String, icon: String, subtitle: String? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.medium))
                .foregroundColor(.brownLeather)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.scoreDream(.bold, size: .body))
                    .foregroundColor(.primaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText.opacity(0.8))
                }
            }
            
            Spacer()
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.antiqueGold.opacity(0.8),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: 60)
        }
    }
    
    // MARK: - Methods
    
    private func addKeyword() {
        let trimmedKeyword = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedKeyword.isEmpty && keywords.count < 5 {
            if keywords.contains(trimmedKeyword) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isShowingDuplicateWarning = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isShowingDuplicateWarning = false
                    }
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    keywords.append(trimmedKeyword)
                    currentInput = ""
                    focusField = .keywords
                }
            }
        }
    }
    
    private func removeKeyword(_ keyword: String) {
        if let index = keywords.firstIndex(of: keyword) {
            keywords.remove(at: index)
        }
    }
    
    private func submitStory() {
        guard isFormValid else {
            updateFeedbackMessage()
            return
        }
        
        storiesViewModel.createBookStory(
            images: selectedImages,
            bookId: book.id,
            quote: quote,
            content: content,
            isPublic: isPublic,
            keywords: keywords,
            folderIds: themeIds
        ) { isSuccess in
            if isSuccess {
                alertType = .make
                alertMessage = "북스토리가 성공적으로 등록되었어요!"
                showAlert = true
            } else {
                alertType = .make
                alertMessage = "북스토리 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                showAlert = true
            }
        }
    }
    
    private func updateFeedbackMessage() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            saveDraftSuccessPrompt = false  // 에러메시지에는 임시저장 성공 알림 프롬프트 비활성화
            if keywords.isEmpty {
                feedbackMessage = "키워드를 입력해주세요."
            } else if quote.isEmpty {
                feedbackMessage = "인용문을 입력해주세요."
            } else if content.isEmpty {
                feedbackMessage = "내용을 입력해주세요."
            } else {
                feedbackMessage = nil
            }
        }
    }
    
    private func showPrompt() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            saveDraftSuccessPrompt = true
            feedbackMessage = "임시저장 완료!"
        }
        
        // 2초 후 자동으로 사라지도록
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                feedbackMessage = nil
                saveDraftSuccessPrompt = false
            }
        }
    }
}

// MARK: - Extensions

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
