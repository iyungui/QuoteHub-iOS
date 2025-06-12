//
//  ListQuotesRecordView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/11/25.
//

import SwiftUI

// MARK: - LIST QUOTES RECORD VIEW

struct ListQuotesRecordView: View {
    @EnvironmentObject var formViewModel: StoryFormViewModel
    var quotePageAndTextFocused: FocusState<BookStoryFormField?>.Binding
    
    var body: some View {
        VStack(spacing: 0) {
            // 기존 quotes 리스트 (내용이 있는 quote가 하나라도 있을 때만 표시)
            if formViewModel.quotes.contains(where: { !$0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                quotesListSection
            }
            
            Spacer()
            
            // 새로운 quote 입력창
            newQuoteInputSection
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                quotePageAndTextFocused.wrappedValue = .quotePage
            }
        }
    }
    
    // MARK: - Quotes List Section
    
    private var quotesListSection: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(formViewModel.quotes.enumerated()), id: \.element.id) { index, quote in
                    if !quote.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        quoteItemCard(quote: quote, index: index)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
    
    private func quoteItemCard(quote: Quote, index: Int) -> some View {
        VStack(spacing: 0) {
            // 페이지 정보 (있는 경우에만)
            HStack {
                if let page = quote.page {
                    Text("p. \(page)")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText)
                }
                Spacer()
                
                // 삭제 버튼
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        formViewModel.removeQuote(at: index)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .fill(Color.paperBeige.opacity(0.3))
            )
            
            // Quote 텍스트
            VStack(alignment: .leading, spacing: 8) {
                Text(quote.quote)
                    .font(.scoreDream(.regular, size: .body))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color.lightPaper.opacity(0.1))
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.lightPaper, lineWidth: 1)
        )
    }
    
    // MARK: - New Quote Input Section
    
    private var newQuoteInputSection: some View {
        VStack(spacing: 0) {
            // 페이지 번호 입력
            HStack {
                TextField(
                    text: $formViewModel.currentQuotePage,
                    prompt: Text("p. (선택)")
                        .font(.scoreDream(.extraLight, size: .subheadline))
                        .foregroundStyle(Color.secondaryText.opacity(0.7))
                ) { }
                .focused(quotePageAndTextFocused, equals: .quotePage)
                .font(.scoreDream(.regular, size: .callout))
                .keyboardType(.numberPad)
                .submitLabel(.next)
                .onSubmit {
                    quotePageAndTextFocused.wrappedValue = .quoteText
                }
                
                Spacer()
                
                StoryCharacterCountView(
                    currentInputCount: formViewModel.currentQuoteText.count,
                    maxCount: formViewModel.quoteMaxLength
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(Color.paperBeige.opacity(0.3))
                    .overlay(
                        Rectangle()
                            .stroke(Color.brownLeather.opacity(0.1), lineWidth: 0.5)
                    )
            )
            .cornerRadius(10, corners: [.topLeft, .topRight])
            
            // Quote 텍스트 입력
            CustomTextEditor(
                text: $formViewModel.currentQuoteText,
                placeholder: formViewModel.quotePlaceholder,
                minHeight: 100,
                maxLength: formViewModel.quoteMaxLength,
                isFocused: quotePageAndTextFocused.wrappedValue == .quoteText
            )
            .focused(quotePageAndTextFocused, equals: .quoteText)
            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
            
            HStack {
                Spacer()
                // 추가 버튼
                Button {
                    formViewModel.addCurrentQuote()
                    quotePageAndTextFocused.wrappedValue = nil
                } label: {
                    HStack(spacing: 8) {
                        Text("문장 추가")
                            .font(.scoreDreamBody)
                            .foregroundStyle(Color.white)
                            
                        Image("custom.pencil.line.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .font(.body)
                            .frame(height: 24)
                    }
                }
                .disabled(formViewModel.currentQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(8)
                .background(formViewModel.currentQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                .opacity(formViewModel.currentQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 1.0)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top)
        }
        .padding(16)
    }
}
