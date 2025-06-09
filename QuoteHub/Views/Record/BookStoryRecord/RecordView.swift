//
//  RecordView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
//import SwiftData
import SDWebImageSwiftUI

/// 북스토리 기록 3: 북스토리 기록 뷰
struct RecordView: View {
    
    // MARK: - PROPERTIES
    
    let book: Book
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var formViewModel = StoryFormViewModel()

    // MARK: - BODY
    
    var body: some View {
        ZStack {
            StoryBackgroundGradient()
            
            ScrollView {
                VStack(spacing: 30) {
                    // 책 정보 카드
                    BookInfoCard(book: book)
                    
                    // 인용구 입력 카드
                    QuotesInputCard(viewModel: formViewModel)
                    
                    // 생각 입력 카드
                    ThoughtInputCard(viewModel: formViewModel)
                    
                    // 이미지 추가 카드
                    StoryImagesView(selectedImages: $formViewModel.selectedImages, showingImagePicker: $formViewModel.showingImagePicker)
                    
                    // 설정 카드들
                    VStack(spacing: 16) {
                        ThemeSelectionCard(viewModel: formViewModel)
                        PrivacyToggleCard(viewModel: formViewModel)
                    }
                    
                    // 키워드 입력 카드
                    KeywordInputCard(viewModel: formViewModel)
                    
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
            //            ToolbarItem(placement: .topBarTrailing) {
            //                draftSaveButton
            //            }
            // 등록 버튼
            ToolbarItem(placement: .primaryAction) {
                submitButton
            }
            // 피드백 메시지
            ToolbarItem(placement: .navigation) {
                // 북스토리 생성가능해지면 자동으로 피드백메시지 사라지도록
                // 그리고 임시저장 기능 메시지 활성화 시에도 피드백메시지 보이도록
                if let message = formViewModel.feedbackMessage, (!formViewModel.isQuotesFilled/* || saveDraftSuccessPrompt*/) {
                    FeedbackView(message: message)
                }
            }
        }
        .progressOverlay(viewModel: storiesViewModel, animationName: "progressLottie", opacity: true)
        .photoPickerSheet(viewModel: formViewModel)
        .storyFormAlert(viewModel: formViewModel, onSuccess: {
            dismiss()
        })
    }
    
    // MARK: - UI COMPONENTS
    
    private var submitButton: some View {
        Button(action: submitStory) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(formViewModel.isQuotesFilled ? .appAccent : .gray)
                    .scaleEffect(formViewModel.isQuotesFilled ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: formViewModel.isQuotesFilled)
                if formViewModel.isQuotesFilled {
                    Text("등록")
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }

    /// 북스토리 생성 액션
    private func submitStory() {
        
        // quote가 채워져 있지 않다면 피드백 메시지와 함께 return
        guard formViewModel.isQuotesFilled else {
            formViewModel.updateFeedbackMessage()
            return
        }
        // 옵셔널 처리
        let retContent = formViewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : formViewModel.content
        let retImages = formViewModel.selectedImages.isEmpty ? nil : formViewModel.selectedImages
        let retKeywords = formViewModel.keywords.isEmpty ? nil : formViewModel.keywords
        let retThemeIds = formViewModel.themeIds.isEmpty ? nil : formViewModel.themeIds

        storiesViewModel.createBookStory(
            bookId: book.id,
            quotes: formViewModel.quotes,
            images: retImages,
            content: retContent,
            isPublic: formViewModel.isPublic,
            keywords: retKeywords,
            themeIds: retThemeIds
        ) { isSuccess in
            if isSuccess {
                formViewModel.alertType = .make
                formViewModel.alertMessage = "북스토리가 성공적으로 등록되었어요!"
                formViewModel.showAlert = true
            } else {
                formViewModel.alertType = .make
                formViewModel.alertMessage = "북스토리 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                formViewModel.showAlert = true
            }
        }
    }
}


// MARK: - View Extensions

extension View {
    func photoPickerSheet(viewModel: StoryFormViewModel) -> some View {
        self
            .sheet(isPresented: .constant(viewModel.showingCamera)) {
                ImagePicker(selectedImages: .constant(viewModel.selectedImages), sourceType: viewModel.sourceType)
                    .ignoresSafeArea(.all)
            }
            .sheet(isPresented: .constant(viewModel.showingGallery)) {
                MultipleImagePicker(
                    selectedImages: .constant(viewModel.selectedImages),
                    selectionLimit: max(0, 10 - viewModel.selectedImages.count)
                )
                .ignoresSafeArea(.all)
            }
            .actionSheet(isPresented: .constant(viewModel.showingImagePicker)) {
                ActionSheet(title: Text("이미지 선택"), message: nil, buttons: [
                    .default(Text("카메라")) {
                        viewModel.sourceType = .camera
                        PermissionsManager.shared.checkCameraAuthorization { authorized in
                            if authorized {
                                viewModel.showingCamera = true
                            } else {
                                viewModel.alertType = .authorized
                                viewModel.alertMessage = "북스토리에 이미지를 업로드하려면 카메라 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
                                viewModel.showAlert = true
                            }
                        }
                    },
                    .default(Text("사진 라이브러리")) {
                        viewModel.sourceType = .photoLibrary
                        PermissionsManager.shared.checkPhotosAuthorization { authorized in
                            if authorized {
                                viewModel.showingGallery = true
                            } else {
                                viewModel.alertType = .authorized
                                viewModel.alertMessage = "북스토리에 이미지를 업로드하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
                                viewModel.showAlert = true
                            }
                        }
                    },
                    .cancel()
                ])
            }
    }
    
    func storyFormAlert(viewModel: StoryFormViewModel, onSuccess: @escaping () -> Void) -> some View {
        self.alert(isPresented: .constant(viewModel.showAlert)) {
            switch viewModel.alertType {
            case .authorized:
                return Alert(
                    title: Text("권한 필요"),
                    message: Text(viewModel.alertMessage),
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
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("확인"), action: {
                        if viewModel.alertMessage.contains("성공적으로") {
                            onSuccess()
                        }
                    })
                )
            }
        }
    }
}


#Preview {
    RecordView(
        book: Book(title: "", author: [], translator: [], introduction: "", publisher: "", publicationDate: "", bookImageURL: "", bookLink: "", ISBN: [], _id: ""))
    .environmentObject(BookStoriesViewModel())
}
