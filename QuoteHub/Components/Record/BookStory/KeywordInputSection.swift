//
//  KeywordInputSection.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

struct KeywordInputSection: View {
    @EnvironmentObject var formViewModel: StoryFormViewModel
    var keywordFocused: FocusState<BookStoryFormField?>.Binding
    
    var body: some View {
        VStack(spacing: 8) {
            // 키워드 입력 텍스트필드
            HStack {
                TextField("#키워드 입력", text: $formViewModel.inlineKeywordInput)
                    .focused(keywordFocused, equals: .keyword)
                    .font(.appFont(.medium, size: .callout))
                    .submitLabel(.continue)
                    .onChange(of: formViewModel.inlineKeywordInput) { _, newValue in
                        formViewModel.processInlineKeywordInput(newValue)
                    }
                    .onSubmit {
                        formViewModel.processInlineKeywordInput(formViewModel.inlineKeywordInput + " ")
                    }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.leading, 20)
            .padding(.vertical, 8)
            
            // 피드백 메시지
            if let feedback = formViewModel.inlineKeywordFeedback {
                HStack {
                    Text(feedback)
                        .font(.appFont(.medium, size: .caption2))
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.horizontal, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // 키워드 칩들
            if !formViewModel.keywords.isEmpty {
                keywordChipsSection
            }
        }
        .background(Color.clear)
    }
    
    private var keywordChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(formViewModel.keywords.enumerated()), id: \.element) { index, keyword in
                    keywordChip(keyword: keyword)
                }
            }
            .padding(.horizontal, 11)
        }
        .frame(height: 30)
    }
    
    private func keywordChip(keyword: String) -> some View {
        HStack(spacing: 4) {
            Text("#\(keyword)")
                .font(.appFont(.medium, size: .caption))
                .foregroundColor(.secondary)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    formViewModel.removeInlineKeyword(keyword)
                }
            }) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.1))
        )
    }
}
