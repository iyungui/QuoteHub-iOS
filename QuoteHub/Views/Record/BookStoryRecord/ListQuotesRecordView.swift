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
    
    @State private var scrollPosition: UUID? = nil
    
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
    }
    
    // MARK: - Quotes List Section
    
    private var quotesListSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(formViewModel.quotes.enumerated()), id: \.element.id) { index, quote in
                        if !quote.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            quoteItemCard(quote: quote, index: index)
                                .id(quote.id)  // ScrollViewReader용 ID
                        }
                    }
                }
                .padding(.top, 22)
            }
            .scrollPosition(id: $scrollPosition)
            .onChange(of: formViewModel.quotes.count) { oldCount, newCount in
                // quote가 추가되거나 삭제되었을 때 마지막 quote로 스크롤
                if newCount != oldCount {
                    // 내용이 있는 마지막 quote 찾기
                    if let lastQuote = formViewModel.quotes.last(where: { !$0.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
                        scrollPosition = lastQuote.id
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo(lastQuote.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
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
            .padding(.horizontal, 16)   // 안쪽 패딩
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
        .padding(.horizontal, 25)   // 바깥쪽 패딩
    }
    
    // MARK: - New Quote Input Section
    
    private var newQuoteInputSection: some View {
        VStack(spacing: 0) {
            // 페이지 번호 입력 & 글자수 표시 & 문장 추가
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
                
                // 문장 추가 버튼
                Button {
                    formViewModel.addCurrentQuote()
                } label: {
                    Text("추가")
                        .font(.scoreDream(.medium, size: .caption))
                        .foregroundColor(formViewModel.currentQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary.opacity(0.5) : .blue)
                }
                .disabled(formViewModel.currentQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)   // 안쪽패딩
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
            .padding(.horizontal, 25)   // 바깥쪽 패딩

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
            .padding(.horizontal, 25)   // 바깥쪽 패딩

            
            KeywordInputSection(keywordFocused: quotePageAndTextFocused)
                .environmentObject(formViewModel)
        }
    }
}
