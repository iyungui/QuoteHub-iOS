//
//  QuotesInputCard.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

/// 북스토리 기록 - 문장 입력 카드
struct QuotesInputCard: View {

    @EnvironmentObject var viewModel: StoryFormViewModel
    var quotePageAndTextFocused: FocusState<BookStoryFormField?>.Binding
    
    private var quoteTextIsEmpty: Bool {
        viewModel.currentQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 16) {
            CardHeader(title: "문장(필수)", icon: "quote.opening", subtitle: "마음에 드는 문장을 기록해보세요")
            
            /// 문장 목록 섹션
            quoteListSection
            
            /// 문장 추가 섹션
            quoteAddSection
        }
    }
    
    // MARK: - UI Components
    
    private var quoteListSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(viewModel.quotes.enumerated()), id: \.offset) { index, quote in
                QuoteItemView(quote: quote, index: index, onRemove: viewModel.removeQuote)
            }
        }
    }
    
    private var quoteAddSection: some View {
        VStack(spacing: 12) {
            // 페이지 번호 입력
            HStack {
                TextField("페이지 입력 (선택)", text: $viewModel.currentQuotePage)
                    .focused(quotePageAndTextFocused, equals: .quotePage)
                    .keyboardType(.numberPad)
                    .font(.scoreDream(.medium, size: .body))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.paperBeige.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(quotePageAndTextFocused.wrappedValue == .quotePage ? Color.brownLeather.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: quotePageAndTextFocused.wrappedValue)

            // 문장 텍스트 입력
            VStack(spacing: 8) {
                CustomTextEditor(
                    text: $viewModel.currentQuoteText,
                    placeholder: viewModel.quotePlaceholder,
                    minHeight: 80,
                    maxLength: viewModel.quoteMaxLength,
                    isFocused: quotePageAndTextFocused.wrappedValue == .quoteText
                )
                .focused(quotePageAndTextFocused, equals: .quoteText)

                StoryCharacterCountView(currentInputCount: viewModel.currentQuoteText.count, maxCount: viewModel.quoteMaxLength)
            }
            
            // 문장 추가 버튼
            Button(action: viewModel.addQuote) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.brownLeather)
                    Text("문장 추가")
                        .font(.scoreDream(.medium, size: .body))
                        .foregroundStyle(Color.primaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.antiqueGold.opacity(0.2))
                )
            }
            .disabled(quoteTextIsEmpty)
            .opacity(quoteTextIsEmpty ? 0.5 : 1.0)
        }
    }
}

// MARK: - Quote Item View

/// 추가된 문장 row 뷰
struct QuoteItemView: View {
    let quote: Quote
    let index: Int
    let onRemove: (Int) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(quote.quote)
                    .font(.scoreDream(.regular, size: .body))
                    .foregroundColor(.primaryText)
                
                if let page = quote.page {
                    Text("p. \(page)")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    onRemove(index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.antiqueGold.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.antiqueGold.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview {
    @FocusState var focusField: BookStoryFormField?
    QuotesInputCard(quotePageAndTextFocused: $focusField).environmentObject(StoryFormViewModel())
}
