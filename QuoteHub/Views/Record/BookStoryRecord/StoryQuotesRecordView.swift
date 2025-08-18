//
//  StoryQuotesRecordView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import Combine

/// 북스토리 기록 3: 북스토리 기록 뷰

enum BookStoryFormField: Hashable {
    case quotePage
    case quoteText
    case content
    case keyword
}

struct StoryQuotesRecordView: View {
    let book: Book
    let storyId: String?    // 북스토리 수정 시 사용
    let shouldLoadDraft: Bool // 임시저장 불러오기 여부
    
    var isEditMode: Bool { storyId != nil }
    
    init(book: Book, storyId: String? = nil, shouldLoadDraft: Bool = false) {
        self.book = book
        self.storyId = storyId
        self.shouldLoadDraft = shouldLoadDraft
    }

    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var formViewModel = StoryFormViewModel()
    @State private var draftManager: DraftManager?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showDraftSavedFeedback = false
    
    @FocusState private var focusedField: BookStoryFormField?
    
    var body: some View {
        VStack {
            if formViewModel.isCarouselView {
                CarouselQuotesRecordView(
                    focusFields: $focusedField
                )
            } else {
                ListQuotesRecordView(
                    quotePageAndTextFocused: $focusedField
                )
            }
            
            Spacer()
        }
        .backgroundGradient()
        .alert("알림", isPresented: $formViewModel.showAlert) {
            Button("확인") {}
        } message: {
            Text(formViewModel.alertMessage)
        }
        .sheet(isPresented: $formViewModel.showingOCRPreview) {
            OCRPreviewSheet(
                extractedText: $formViewModel.extractedOCRText,
                originalImage: formViewModel.selectedOCRImage,
                onApply: { text in
                    formViewModel.applyOCRTextToQuote(text)
                },
                onCancel: {
                    formViewModel.cancelOCR()
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(isEditMode ? "북스토리 수정" : "북스토리 기록")
        .toolbar {
            toolBarItems
        }
        .onAppear {
            setupDraftManager()
            setupAutoSave()
        }
        .onDisappear {
            saveOnDisappear()
        }
        .task {
            await loadDataIfNeeded()
        }
        .environmentObject(formViewModel)
        .progressOverlay(viewModel: myBookStoriesViewModel, opacity: false)
        .overlay(
            // 임시저장 완료 피드백
            VStack {
                if showDraftSavedFeedback {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("임시저장 완료")
                            .font(.appFont(.medium, size: .caption))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 4)
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                Spacer()
            }
            .padding(.top, 100)
        )
    }
    
    private var toolBarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 0) {
                    Button {
                        saveManualDraft()
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .offset(y: -2)
                    }
                    .hidden(!formViewModel.hasValueForDraft)
                    
                    Button {
                        formViewModel.isCarouselView.toggle()
                    } label: {
                        Image(systemName:
                                formViewModel.isCarouselView ? "square.3.layers.3d.down.backward" : "list.bullet.below.rectangle")
                        .scaleEffect(x: 1, y: formViewModel.isCarouselView ? 1 : -1)
                    }
                }
            }
            
            ToolbarItem(placement: .navigation) {
                if let message = formViewModel.feedbackMessage, !formViewModel.isQuotesFilled {
                    FeedbackView(message: message).environmentObject(formViewModel)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                nextButton
            }
            
            // MARK: - KEYBOARD DISMISS
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    
                    Button {
                        focusedField = nil
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
        }
    }
    
    private var nextButton: some View {
        NavigationLink {
            StorySettingRecordView(book: book, storyId: storyId)
                .environmentObject(formViewModel)
        } label: {
            Text("다음")
                .foregroundStyle(formViewModel.isQuotesFilled ? Color.blue : Color.gray.opacity(0.7))
        }
        .disabled(!formViewModel.isQuotesFilled)
    }
    
    // MARK: - Setup Methods
    
    private func setupDraftManager() {
        draftManager = DraftManager(modelContext: modelContext)
    }
    
    private func setupAutoSave() {
        // 키워드, 인용구, 내용, 이미지 변경 시 자동저장 트리거
        Publishers.CombineLatest4(
            formViewModel.$keywords,
            formViewModel.$quotes,
            formViewModel.$content,
            formViewModel.$selectedImages
        )
        .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
        .sink { _, _, _, _ in
            startAutoSave()
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    private func loadDataIfNeeded() async {
        if let storyId = storyId {
            // 수정 모드: 기존 스토리 불러오기
            await loadExistingStory(storyId: storyId)
        } else if shouldLoadDraft {
            // 임시저장 불러오기 모드
            await loadDraftData()
        }
    }
    
    private func loadDraftData() async {
        guard let draftManager = draftManager else { return }
        
        if let draft = await draftManager.loadDraft(for: book.id) {
            await MainActor.run {
                draftManager.applyDraftToViewModel(draft, viewModel: formViewModel)
                print("✅ 임시저장 데이터 불러오기 완료")
            }
        }
    }
    
    private func loadExistingStory(storyId: String) async {
        let loadedStory = await myBookStoriesViewModel.fetchSpecificBookStory(storyId: storyId)
        
        guard let loadedStory = loadedStory else {
            formViewModel.showAlert = true
            formViewModel.alertMessage = myBookStoriesViewModel.errorMessage ?? "북스토리를 불러오지 못했어요."
            return
        }
        
        formViewModel.loadFromBookStory(loadedStory)
    }
    
    // MARK: - Draft Save Methods
    
    private func startAutoSave() {
        guard formViewModel.hasValueForDraft else { return }
        draftManager?.startAutoSaveFromViewModel(book: book, viewModel: formViewModel)
    }
    
    private func saveManualDraft() {
        guard formViewModel.hasValueForDraft else { return }
        
        Task {
            await draftManager?.saveDraftFromViewModel(book: book, viewModel: formViewModel)
            
            await MainActor.run {
                showDraftSavedFeedback = true
                
                // 2초 후 피드백 숨김
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showDraftSavedFeedback = false
                    }
                }
            }
        }
    }
    
    private func saveOnDisappear() {
        // 자동저장 중지
        draftManager?.stopAutoSave()
        
        // 마지막 수동 저장 (데이터가 있는 경우에만)
        if formViewModel.hasValueForDraft {
            Task {
                await draftManager?.saveDraftFromViewModel(book: book, viewModel: formViewModel)
                print("📝 뷰 종료 시 마지막 임시저장 완료")
            }
        }
    }
}

#Preview {
    NavigationStack {
        StoryQuotesRecordView(book: Book.previewBook)
            .environmentObject(StoryFormViewModel())
            .environment(MyBookStoriesViewModel())
    }
}
