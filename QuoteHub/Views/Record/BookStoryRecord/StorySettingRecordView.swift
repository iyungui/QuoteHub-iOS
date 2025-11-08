//
//  StorySettingRecordView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/11/25.
//

import SwiftUI
import StoreKit

struct StorySettingRecordView: View {
    let book: Book
    let storyId: String?
    var isEditMode: Bool { storyId != nil }
    
    @EnvironmentObject private var formViewModel: StoryFormViewModel
    
    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(TabManager.self) private var tabController
    @Environment(\.requestReview) private var requestReview
    
    /// 스토리 완성 횟수 추적 (리뷰 요청 조건)
    @AppStorage("storyCompletedCount") private var storyCompletedCount = 0
    
    /// 마지막으로 리뷰를 요청한 앱 버전
    @AppStorage("lastVersionPromptedForReview") private var lastVersionPromptedForReview = ""
    
    private var draftManager: DraftManager {
        DraftManager(modelContext: modelContext)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ThemeSelectionCard()
            PrivacyToggleCard()
            thoughtSheetButton
            
            Spacer()
        }
        // 오류 났을 때 alert
        .alert("알림", isPresented: $formViewModel.showAlert, actions: {
            Button("확인") { }
        }, message: {
            Text(formViewModel.alertMessage)
        })
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .backgroundGradient()
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(formViewModel)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                submitButton(viewModel: formViewModel)
            }
        }
        .sheet(isPresented: $formViewModel.showingContentSheet) {
            ThoughtInputCard(book: book)
                .environmentObject(formViewModel)
        }
        .progressOverlay(viewModel: myBookStoriesViewModel, opacity: true)
    }
    
    private var thoughtSheetButton: some View {
        Button {
            formViewModel.showingContentSheet = true
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("마음에 남은 이야기 적기")
                        .font(.appFont(.medium, size: .body))
                        .foregroundColor(.primaryText)
                    
                    Text("이미지와 함께 북스토리를 풍성하게 만들 수 있어요.")
                        .font(.appFont(.light, size: .caption))
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondaryText.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.paperBeige.opacity(0.3))
            )
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Extensions

extension StorySettingRecordView {
    
    private func submitButton(viewModel: StoryFormViewModel) -> some View {
        Button(action: submitStory) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.callout)
                    .foregroundStyle(Color.blue)
                    
                Text("이대로 작성")
                    .font(.appFont(.medium, size: .callout))
                    .foregroundStyle(Color.blue)
            }
        }
        .disabled(!formViewModel.isQuotesFilled)
    }
    
    private func submitStory() {
        // 검증 로직
        guard let validQuotes = validateQuotes() else {
            return
        }
        
        Task {
            await performSubmitStory(validQuotes)
        }
    }
    
    private func performSubmitStory(_ validQuotes: [Quote]) async {
        // 옵셔널 처리
        let retContent = formViewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : formViewModel.content
        let retImages = formViewModel.selectedImages.isEmpty ? nil : formViewModel.selectedImages
        let retKeywords = formViewModel.keywords.isEmpty ? nil : formViewModel.keywords
        let retThemeIds = formViewModel.themeIds.isEmpty ? nil : formViewModel.themeIds
        
        let resultStory: BookStory?
        
        // 모드에 따라 resultStory에 담기. nil이면 fail
        if isEditMode, let storyId = storyId {
            resultStory = await myBookStoriesViewModel.updateBookStory(
                storyId: storyId,
                quotes: validQuotes,
                images: retImages,
                content: retContent,
                isPublic: formViewModel.isPublic,
                keywords: retKeywords,
                themeIds: retThemeIds
            )
        } else {
            resultStory = await myBookStoriesViewModel.createBookStory(
                bookId: book.id,
                quotes: validQuotes,
                images: retImages,
                content: retContent,
                isPublic: formViewModel.isPublic,
                keywords: retKeywords,
                themeIds: retThemeIds
            )
        }
        
        handleSubmissionResult(story: resultStory, isEdit: isEditMode)
    }
    
    private func handleSubmissionResult(story: BookStory?, isEdit: Bool) {
        if let story = story {
            // 스토리 작성 성공한 경우
            // 임시저장 삭제
            draftManager.clearDraft(for: book.id)
            
            // 리뷰 요청 고려
            requestReviewIfNeeded()
            
            // 해당 스토리 페이지로 navigate
            tabController.navigateToStory(story)
        } else {
            // 북스토리 작성 실패한 경우
            formViewModel.alertType = .make
            formViewModel.alertMessage = isEdit ?
                "북스토리 수정 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요." :
                "북스토리 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
            formViewModel.showAlert = true
        }
    }
    
    private func validateQuotes() -> [Quote]? {
        guard formViewModel.isQuotesFilled else {
            formViewModel.updateFeedbackMessage()
            return nil
        }
        
        // quotes 처리 - 빈 quote 제거하고 최소 하나는 보장
        let validQuotes = formViewModel.quotes.filter {
            !$0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        guard !validQuotes.isEmpty else {
            formViewModel.alertMessage = "최소 하나의 인용구가 필요합니다."
            formViewModel.showAlert = true
            return nil
        }
        
        return validQuotes
    }
    
    // 리뷰 요청 조건 확인 후 요청
    private func requestReviewIfNeeded() {
        // 수정 모드에서는 리뷰 요청x
        guard !isEditMode else { return }
        
        // 스토리 완성 횟수 증가
        storyCompletedCount += 1
        
        guard let currentAppVersion = Bundle.currentAppVersion else {
            print("Unable to get current app version for review request")
            return
        }
        
        // 리뷰 요청 조건:
        // 1. 2번 이상 스토리 완성
        // 2. 현재 버전에서 아직 리뷰 요청하지 않았을 때
        let shouldRequestReview: Bool = storyCompletedCount >= 2 && currentAppVersion != lastVersionPromptedForReview
        
        guard shouldRequestReview else { return }
        
        presentReview()
        
        // store current version
        lastVersionPromptedForReview = currentAppVersion
    }
    
    private func presentReview() {
        Task {
            try await Task.sleep(for: .seconds(2))
            requestReview()
        }
    }
}

#Preview {
    NavigationStack {
        StorySettingRecordView(book: Book.previewBook, storyId: nil)
        .environmentObject(StoryFormViewModel())
        .environment(MyBookStoriesViewModel())
    }
}
