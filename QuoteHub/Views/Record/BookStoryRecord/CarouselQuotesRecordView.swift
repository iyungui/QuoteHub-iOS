//
//  CarouselQuotesRecordView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/11/25.
//

import SwiftUI

// MARK: - CAROUSEL QUOTES RECORD VIEW

struct CarouselQuotesRecordView: View {
    @EnvironmentObject var formViewModel: StoryFormViewModel
    var focusFields: FocusState<BookStoryFormField?>.Binding
    
    @State private var currentQuoteIndex: Int = 0
    @State private var scrollPosition: UUID? = nil

    let width: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(Array(formViewModel.quotes.enumerated()), id: \.element.id) { index, quote in
                                quoteInputCard(quote: quote, index: index)
                                    .id(quote.id)  // for scroll reader
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: $scrollPosition)
                    .onChange(of: scrollPosition) { _, newValue in
                        if let newUUID = newValue,
                           let newIndex = formViewModel.quotes.firstIndex(where: { $0.id == newUUID }) {
                            currentQuoteIndex = newIndex
                        }
                    }
                    .onChange(of: formViewModel.quotes.count) { oldCount, newCount in
                        // quote가 추가되었을 때 새로 추가된 페이지로 이동
                        print(oldCount, newCount)
                        if newCount > oldCount {
                            let newIndex = min(currentQuoteIndex + 1, newCount - 1)
                            currentQuoteIndex = newIndex
                            
                            if newIndex < formViewModel.quotes.count {
                                let targetQuoteId = formViewModel.quotes[newIndex].id
                                scrollPosition = targetQuoteId
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo(targetQuoteId, anchor: .center)
                                    }
                                }
                            }
                        }
                        // quote 삭제 시 이전 페이지로 이동
                        else if newCount < oldCount {
                            let newIndex = max(0, min(currentQuoteIndex - 1, newCount - 1))
                            currentQuoteIndex = newIndex
                            
                            if newIndex < formViewModel.quotes.count {
                                let targetQuoteId = formViewModel.quotes[newIndex].id
                                scrollPosition = targetQuoteId
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo(targetQuoteId, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                }
                KeywordInputSection(keywordFocused: focusFields)
                    .environmentObject(formViewModel)
                    .offset(y: -10)
            }
            HStack(spacing: 10) {
                Button {
                    // quote 입력 페이지 삭제 (현재 index)
                    focusFields.wrappedValue = nil
                    formViewModel.removeQuote(at: currentQuoteIndex)
                } label: {
                    Image("custom.book.pages.badge.minus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.2/2)
                }
                // quote가 하나도 없으면 hidden (최소 하나는 유지)
                .disabled(formViewModel.quotes.count <= 1)
                .opacity(formViewModel.quotes.count <= 1 ? 0.4 : 1.0)
                
                Divider().background(Color.white)
                
                Button {
                    // quote 입력 페이지 추가 (현재 index 바로 앞에)
                    focusFields.wrappedValue = nil
                    formViewModel.addQuote(at: currentQuoteIndex)
                } label: {
                    Image("custom.book.pages.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width * 0.2/2)
                }
            }
            .padding(8)
            .frame(maxHeight: 40)
            .background(Color.inkBrown)
            .clipShape(Capsule())
            .offset(y: 8)
            .shadow(color: .gray, radius: 2)
        }
        .contentMargins(32)
        .scrollTargetBehavior(.paging)
        .frame(height: width <= 375 ? width * 0.8 : width)
    }
    
    private func quoteInputCard(quote: Quote, index: Int) -> some View {
        VStack(spacing: 0) {
            quotePageInputSection(for: index)
            CustomTextEditor(
                text: $formViewModel.quotes[index].quote,
                placeholder: formViewModel.quotePlaceholder,
                minHeight: 200,
                maxLength: formViewModel.quoteMaxLength,
                isFocused: focusFields.wrappedValue == .quoteText
            )
            .focused(focusFields, equals: .quoteText)
        }
        .containerRelativeFrame(.horizontal)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func quotePageInputSection(for index: Int) -> some View {
        let quote = formViewModel.quotes[index]
        return HStack {
            TextField(
                text: formViewModel.pageBinding(for: quote.id),
                prompt: Text("p. (선택)")
                    .font(.scoreDream(.extraLight, size: .subheadline))
                    .foregroundStyle(Color.secondaryText.opacity(0.7))
            ) { }
            .focused(focusFields, equals: .quotePage)
            .font(.scoreDream(.regular, size: .callout))
            .keyboardType(.numberPad)
            .submitLabel(.next) // 키보드에 '다음'버튼으로 표시
            .onSubmit {
                focusFields.wrappedValue = .quoteText   // 다음 버튼 누르면 quoteText로 포커스 이동
            }
            
            Spacer()
            
            StoryCharacterCountView(currentInputCount: formViewModel.quotes[index].quote.count, maxCount: formViewModel.quoteMaxLength)
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
    }
}
