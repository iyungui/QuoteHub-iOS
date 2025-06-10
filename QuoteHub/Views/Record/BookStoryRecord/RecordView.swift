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
    let book: Book
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @Environment(\.dismiss) private var dismiss
    
    // ✅ 옵셔널로 변경하고 nil로 시작
    @State private var formViewModel: StoryFormViewModel?

    var body: some View {
        ZStack {
            StoryBackgroundGradient()
            
            if let viewModel = formViewModel {
                // ✅ 뷰모델이 준비된 후에만 렌더링
                contentView(viewModel: viewModel)
            } else {
                // ✅ 로딩 화면
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("북스토리 기록 준비 중...")
                        .font(.scoreDream(.medium, size: .body))
                }
            }
        }
        .onAppear {
            // ✅ 백그라운드에서 뷰모델 초기화
            Task {
                let viewModel = await createViewModelInBackground()
                await MainActor.run {
                    self.formViewModel = viewModel
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("북스토리 기록")
    }
    
    // 백그라운드에서 뷰모델 생성
    private func createViewModelInBackground() async -> StoryFormViewModel {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let viewModel = StoryFormViewModel()
                continuation.resume(returning: viewModel)
            }
        }
    }
    
    // 실제 콘텐츠 (뷰모델이 준비된 후)
    private func contentView(@Bindable viewModel: StoryFormViewModel) -> some View {
        ScrollView {
            VStack(spacing: 40) {
                BookInfoCard(book: book)
                Divider()
                QuotesInputCard(viewModel: viewModel)
                Divider()

                ThoughtInputCard(viewModel: viewModel)
                Divider()

                StoryImagesView(selectedImages: $viewModel.selectedImages, showingImagePicker: $viewModel.showingImagePicker)
                Divider()
                
                ThemeSelectionCard(viewModel: viewModel)
                PrivacyToggleCard(viewModel: viewModel)
                KeywordInputCard(viewModel: viewModel)
                spacer(height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                submitButton(viewModel: viewModel)
            }
            ToolbarItem(placement: .navigation) {
                if let message = viewModel.feedbackMessage, !viewModel.isQuotesFilled {
                    FeedbackView(message: message)
                }
            }
        }
        .progressOverlay(viewModel: storiesViewModel, animationName: "progressLottie", opacity: true)
        .photoPickerSheet(viewModel: viewModel)
        .storyFormAlert(viewModel: viewModel, onSuccess: { dismiss() })
    }
    
    private func submitButton(viewModel: StoryFormViewModel) -> some View {
        Button(action: { submitStory(viewModel: viewModel) }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(viewModel.isQuotesFilled ? .appAccent : .gray)
                    .scaleEffect(viewModel.isQuotesFilled ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isQuotesFilled)
                if viewModel.isQuotesFilled {
                    Text("등록")
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appAccent)
                }
            }
        }
    }
    
    private func submitStory(viewModel: StoryFormViewModel) {
        guard viewModel.isQuotesFilled else {
            viewModel.updateFeedbackMessage()
            return
        }
        
        let retContent = viewModel.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : viewModel.content
        let retImages = viewModel.selectedImages.isEmpty ? nil : viewModel.selectedImages
        let retKeywords = viewModel.keywords.isEmpty ? nil : viewModel.keywords
        let retThemeIds = viewModel.themeIds.isEmpty ? nil : viewModel.themeIds

        storiesViewModel.createBookStory(
            bookId: book.id,
            quotes: viewModel.quotes,
            images: retImages,
            content: retContent,
            isPublic: viewModel.isPublic,
            keywords: retKeywords,
            themeIds: retThemeIds
        ) { isSuccess in
            if isSuccess {
                viewModel.alertType = .make
                viewModel.alertMessage = "북스토리가 성공적으로 등록되었어요!"
                viewModel.showAlert = true
            } else {
                viewModel.alertType = .make
                viewModel.alertMessage = "북스토리 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                viewModel.showAlert = true
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
