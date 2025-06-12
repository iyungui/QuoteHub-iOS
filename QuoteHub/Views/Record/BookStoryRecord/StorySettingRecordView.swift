//
//  StorySettingRecordView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/11/25.
//

import SwiftUI

struct StorySettingRecordView: View {
    let book: Book
    @EnvironmentObject var formViewModel: StoryFormViewModel
    @EnvironmentObject var storiesViewModel: BookStoriesViewModel
    var focusedField: FocusState<BookStoryFormField?>.Binding
    
    var body: some View {
        VStack(spacing: 20) {
            ThemeSelectionCard()
            PrivacyToggleCard()
            thoughtSheetButton
            
            Spacer()
        }
        .progressOverlay(viewModel: storiesViewModel, opacity: true)
        .alert("북스토리 완성!", isPresented: $formViewModel.showAlert, actions: {
            Button("확인") {
            }
        }, message: {
            Text(formViewModel.alertMessage)
        })
        .padding(.horizontal, 16)
        .padding(.top, 20)
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
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(formViewModel)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                submitButton(viewModel: formViewModel)
            }
        }
        .sheet(isPresented: $formViewModel.showingContentSheet) {
            ThoughtInputCard(contentFocused: focusedField, book: book)
                .environmentObject(formViewModel)
        }
    }
    
    private var thoughtSheetButton: some View {
        Button {
            formViewModel.showingContentSheet = true
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("마음에 남은 이야기 적기")
                        .font(.scoreDream(.medium, size: .body))
                        .foregroundColor(.primaryText)
                    
                    Text("이미지와 함께 북스토리를 풍성하게 만들 수 있어요.")
                        .font(.scoreDream(.light, size: .caption))
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
                    .font(.scoreDream(.medium, size: .callout))
                    .foregroundStyle(Color.blue)
            }
        }
        .disabled(!formViewModel.isQuotesFilled)
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
}

#Preview {
    @FocusState var focus: BookStoryFormField?
    return NavigationStack {
        StorySettingRecordView(
            book: Book(title: "", author: [], translator: [], introduction: "", publisher: "", publicationDate: "", bookImageURL: "", bookLink: "", ISBN: [], _id: ""),
            focusedField: $focus
        )
        .environmentObject(StoryFormViewModel())
        .environmentObject(BookStoriesViewModel())
    }
}
