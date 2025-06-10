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

enum BookStoryFormField: Hashable {
    case quotePage
    case quoteText
    case content
    case keyword
}

struct RecordView: View {
    let book: Book
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: BookStoryFormField?
    
    @StateObject private var formViewModel = StoryFormViewModel()
    
    var body: some View {
        ZStack {
            StoryBackgroundGradient()
            ScrollView {
                VStack(spacing: 40) {
                    BookInfoCard(book: book)
                    Divider()
            
                    QuotesInputCard(
                        quotePageAndTextFocused: $focusedField
                    )
                    Divider()

                    ThoughtInputCard(
                        contentFocused: $focusedField
                    )
                    Divider()

                    StoryImagesView(
                        selectedImages: $formViewModel.selectedImages,
                        showingImagePicker: $formViewModel.showingImagePicker)
                    Divider()
                    
                    ThemeSelectionCard()
                    PrivacyToggleCard()
                    KeywordInputCard(
                        keywordFocused: $focusedField
                    )
                    spacer(height: 30)
                }
                .environmentObject(formViewModel)
                
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("북스토리 기록")
        .toolbar {
            toolBarItems
        }
        .progressOverlay(viewModel: storiesViewModel, animationName: "progressLottie", opacity: true)
        .photoPickerSheet(viewModel: formViewModel)
        .storyFormAlert(viewModel: formViewModel, onSuccess: { dismiss() })
    }
    
    private func submitButton(viewModel: StoryFormViewModel) -> some View {
        Button(action: submitStory) {
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
    
    private func submitStory() {
        guard formViewModel.isQuotesFilled else {
            formViewModel.updateFeedbackMessage()
            return
        }
        
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
    
    private var toolBarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .primaryAction) {
                submitButton(viewModel: formViewModel)
            }
            ToolbarItem(placement: .navigation) {
                if let message = formViewModel.feedbackMessage, !formViewModel.isQuotesFilled {
                    FeedbackView(message: message)
                }
            }
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
