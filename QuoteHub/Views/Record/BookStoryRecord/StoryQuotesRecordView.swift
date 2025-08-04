//
//  StoryQuotesRecordView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
//import SwiftData

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
    var isEditMode: Bool { storyId != nil }
    let showDraft: Bool?
    
    init(book: Book, storyId: String? = nil, showDraft: Bool? = false) {
        self.book = book
        self.storyId = storyId
        self.showDraft = showDraft
    }

    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel
    
    @StateObject private var formViewModel = StoryFormViewModel()
    
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(isEditMode ? "북스토리 수정" : "북스토리 기록")
        .toolbar {
            toolBarItems
        }
        .task {
            await loadStoryDataIfNeeded()
        }
        .environmentObject(formViewModel)
        .progressOverlay(viewModel: myBookStoriesViewModel, opacity: false)
    }
    
    private var toolBarItems: some ToolbarContent {
        Group {
            // TODO: 좌측에 임시저장 버튼
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    formViewModel.isCarouselView.toggle()
                } label: {
                    Image(systemName:
                            formViewModel.isCarouselView ? "square.3.layers.3d.down.backward" : "list.bullet.below.rectangle")
                    .scaleEffect(x: 1, y: formViewModel.isCarouselView ? 1 : -1)
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
    
    private func loadStoryDataIfNeeded() async {
        guard let storyId = storyId else {
            // storyId 가 주어지지 않으면 생성 모드이므로 바로 return
            return
        }
        
        let loadedStory = await myBookStoriesViewModel.fetchSpecificBookStory(storyId: storyId)
        
        guard let loadedStory = loadedStory else {
            formViewModel.showAlert = true
            formViewModel.alertMessage = myBookStoriesViewModel.errorMessage ?? "북스토리를 불러오지 못했어요."
            return
        }
        
        formViewModel.loadFromBookStory(loadedStory)
    }
}

#Preview {
    NavigationStack {
        StoryQuotesRecordView(book: Book.previewBook)
            .environmentObject(StoryFormViewModel())
            .environmentObject(MyBookStoriesViewModel())
    }
}
