////
////  UpdateStoryView.swift
////  QuoteHub
////
////  Created by AI Assistant on 6/9/25.
////
//
//import SwiftUI
//import SDWebImageSwiftUI
//
///// 북스토리 수정 뷰
//struct UpdateStoryView: View {
//    
//    // MARK: - PROPERTIES
//    
//    let storyId: String
//    
//    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
//    @Environment(\.dismiss) private var dismiss
//    
//    @State private var formViewModel = StoryFormViewModel()
//    @State private var currentStory: BookStory?
//    @State private var isInitialLoading = true
//    @State private var loadError: String?
//    
//    // 텍스트 포커스 필드
//    @FocusState private var focusedField: BookStoryFormField?
//    
//    // MARK: - BODY
//    
//    var body: some View {
//        ZStack {
//            StoryBackgroundGradient()
//            
//            if isInitialLoading {
//                loadingView
//            } else if let error = loadError {
//                errorView(error)
//            } else if let story = currentStory {
//                contentView(story: story)
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle("북스토리 수정")
//        .onAppear {
//            loadStoryData()
//        }
//    }
//    
//    // MARK: - UI Components
//    
//    private var loadingView: some View {
//        VStack(spacing: 20) {
//            ProgressView()
//                .scaleEffect(1.5)
//                .progressViewStyle(CircularProgressViewStyle(tint: .brownLeather))
//            
//            Text("북스토리를 불러오는 중...")
//                .font(.scoreDream(.medium, size: .body))
//                .foregroundColor(.secondaryText)
//        }
//    }
//    
//    private func errorView(_ error: String) -> some View {
//        VStack(spacing: 20) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .font(.system(size: 50))
//                .foregroundColor(.orange)
//            
//            Text("오류가 발생했습니다")
//                .font(.scoreDream(.bold, size: .title2))
//                .foregroundColor(.primaryText)
//            
//            Text(error)
//                .font(.scoreDream(.medium, size: .body))
//                .foregroundColor(.secondaryText)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 40)
//            
//            Button("다시 시도") {
//                loadStoryData()
//            }
//            .padding(.horizontal, 30)
//            .padding(.vertical, 12)
//            .background(Color.brownLeather)
//            .foregroundColor(.white)
//            .font(.scoreDream(.medium, size: .body))
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//        }
//    }
//    
//    private func contentView(story: BookStory) -> some View {
//        ScrollView {
//            VStack(spacing: 30) {
//                BookInfoCard(book: story.bookId)
//                QuotesInputCard(
//                    viewModel: formViewModel,
//                    quotePageAndTextFocused: $focusedField
//                )
//                ThoughtInputCard(
//                    viewModel: formViewModel,
//                    contentFocused: $focusedField
//                )
//                StoryImagesView(selectedImages: $formViewModel.selectedImages, showingImagePicker: $formViewModel.showingImagePicker)
//                
//                VStack(spacing: 16) {
//                    ThemeSelectionCard(viewModel: formViewModel)
//                    PrivacyToggleCard(viewModel: formViewModel)
//                }
//                
//                KeywordInputCard(
//                    viewModel: formViewModel,
//                    keywordFocused: $focusedField
//                )
//                
//                // 하단 여백
//                Spacer()
//                    .frame(height: 100)
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//        }
//        .toolbar {
//            ToolbarItem(placement: .primaryAction) {
//                updateButton
//            }
//            ToolbarItem(placement: .navigation) {
//                if let message = formViewModel.feedbackMessage, !formViewModel.isQuotesFilled {
//                    FeedbackView(message: message)
//                }
//            }
//            ToolbarItem(placement: .keyboard) {
//                HStack {
//                    Spacer()
//                    Button {
//                        focusedField = nil
//                    } label: {
//                        Image(systemName: "keyboard.chevron.compact.down")
//                    }
//                }
//            }
//        }
//        .progressOverlay(viewModel: storiesViewModel, animationName: "progressLottie", opacity: true)
//        .photoPickerSheet(viewModel: formViewModel)
//        .storyFormAlert(viewModel: formViewModel, onSuccess: {
//            dismiss()
//        })
//    }
//    
//    private var updateButton: some View {
//        Button(action: updateStory) {
//            HStack {
//                Image(systemName: "checkmark.circle.fill")
//                    .foregroundColor(formViewModel.isQuotesFilled ? .appAccent : .gray)
//                    .scaleEffect(formViewModel.isQuotesFilled ? 1.1 : 1.0)
//                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: formViewModel.isQuotesFilled)
//                if formViewModel.isQuotesFilled {
//                    Text("수정 완료")
//                        .fontWeight(.medium)
//                        .foregroundStyle(Color.appAccent)
//                }
//            }
//        }
//    }
//    
//    // MARK: - Methods
//    
//    private func loadStoryData() {
//        isInitialLoading = true
//        loadError = nil
//        
//        storiesViewModel.fetchSpecificBookStory(storyId: storyId) { result in
//            DispatchQueue.main.async {
//                isInitialLoading = false
//                
//                switch result {
//                case .success(let story):
//                    currentStory = story
//                    formViewModel.loadFromBookStory(story)
//                    
//                case .failure(let error):
//                    loadError = "북스토리를 불러올 수 없습니다.\n\(error.localizedDescription)"
//                }
//            }
//        }
//    }
//    
//    private func updateStory() {
//        guard formViewModel.isQuotesFilled else {
//            formViewModel.updateFeedbackMessage()
//            return
//        }
//        
//        guard let story = currentStory else { return }
//        
//        let retContent = formViewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : formViewModel.content
//        let retImages = formViewModel.selectedImages.isEmpty ? nil : formViewModel.selectedImages
//        let retKeywords = formViewModel.keywords.isEmpty ? nil : formViewModel.keywords
//        let retThemeIds = formViewModel.themeIds.isEmpty ? nil : formViewModel.themeIds
//        
//        storiesViewModel.updateBookStory(
//            storyID: story.id,
//            images: retImages,
//            quotes: formViewModel.quotes,
//            content: retContent,
//            isPublic: formViewModel.isPublic,
//            keywords: retKeywords,
//            themeIds: retThemeIds
//        ) { isSuccess in
//            if isSuccess {
//                formViewModel.alertType = .make
//                formViewModel.alertMessage = "북스토리가 성공적으로 수정되었어요!"
//                formViewModel.showAlert = true
//            } else {
//                formViewModel.alertType = .make
//                formViewModel.alertMessage = "북스토리 수정 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
//                formViewModel.showAlert = true
//            }
//        }
//    }
//}
//
//#Preview {
//    NavigationStack {
//        UpdateStoryView(storyId: "")
//            .environmentObject(BookStoriesViewModel())
//    }
//}
