//
//  StoryQuotesRecordView.swift
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

struct StoryQuotesRecordView: View {
    let book: Book
    let storyId: String?    // 북스토리 수정 시 사용
    var isEditMode: Bool { storyId != nil }
    
    init(book: Book, storyId: String? = nil) {
        self.book = book
        self.storyId = storyId
    }

    @EnvironmentObject var storiesViewModel: BookStoriesViewModel
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
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.softBeige.opacity(0.3),
                    Color.lightPaper.opacity(0.2),
                    Color.paperBeige.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .alert("알림", isPresented: $formViewModel.showAlert) {
            Button("확인") {}
        } message: {
            Text(formViewModel.alertMessage)
        }
        
        .environmentObject(formViewModel)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(isEditMode ? "북스토리 수정" : "북스토리 기록")
        .toolbar {
            toolBarItems
        }
        .onAppear {
            loadStoryDataIfNeeded()
        }
        .progressOverlay(viewModel: storiesViewModel, animationName: "progressLottie", opacity: false)
    }
    
    private var toolBarItems: some ToolbarContent {
        Group {
            // TODO: 임시저장 버튼
            
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
                    FeedbackView(message: message)
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
            .environmentObject(storiesViewModel)
        } label: {
            Text("다음")
                .foregroundStyle(formViewModel.isQuotesFilled ? Color.blue : Color.gray.opacity(0.7))
        }
        .disabled(!formViewModel.isQuotesFilled)
    }
    
    private func loadStoryDataIfNeeded() {
        guard let storyId = storyId else { return }
        
        storiesViewModel.fetchSpecificBookStory(storyId: storyId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let story):
                    formViewModel.loadFromBookStory(story)
                case .failure(let error):
                    print("Failed to load story data: \(error.localizedDescription)")
                    formViewModel.alertMessage = "북스토리를 불러오지 못했어요."
                    formViewModel.showAlert = true
                }
            }
        }
    }

}

#Preview {
    NavigationStack {
        StoryQuotesRecordView(
            book: Book(title: "", author: [], translator: [], introduction: "", publisher: "", publicationDate: "", bookImageURL: "", bookLink: "", ISBN: [], _id: ""))
        .environmentObject(BookStoriesViewModel())
    }
}
