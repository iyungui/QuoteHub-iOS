//
//  KeywordBottomInputBar.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

struct KeywordBottomInputBar: View {
    @EnvironmentObject var viewModel: StoryFormViewModel
    var keywordFocused: FocusState<BookStoryFormField?>.Binding
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 경계선
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            VStack(spacing: 6) {
                // 생성 가이드 - 키워드가 없을 때 항상 표시
                if viewModel.keywords.isEmpty {
                    StoryCreateGuideSection(message: "책의 핵심내용을 키워드로 연결하면, 기억력이 80% 올라가요.")
                        .padding(.horizontal, 16)
                }
                
                HStack(alignment: .center) {
                    VStack(spacing: 6) {
                        // 키워드 배열이 10개 미만일 때만 입력 필드 보여주기
                        if viewModel.keywords.count < 10 {
                            inputKeywordSection
                            // 글자수 표시
                            StoryCharacterCountView(currentInputCount: viewModel.currentKeywordInput.count, maxCount: viewModel.keywordMaxLength)
                        }
                        
                        // 경고 메시지 표시
                        if viewModel.isShowingDuplicateWarning {
                            showWarningSection
                        }
                        
                        // 키워드 목록 - 키워드가 있을 때 항상 표시
                        if !viewModel.keywords.isEmpty {
                            keywordListSection
                        }
                    }
                    
                    // 키워드 추가 버튼
                    Button {
                        viewModel.addKeyword()
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.medium)
                            .foregroundStyle(Color.white)
                            .padding(8)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var inputKeywordSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "number")
                    .font(.body)
                    .foregroundStyle(Color.gray.opacity(0.7))
                    .frame(width: 20)
                
                TextField("키워드 입력", text: $viewModel.currentKeywordInput)
                    .focused(keywordFocused, equals: .keyword)
                    .submitLabel(.done)
                    .onChange(of: viewModel.currentKeywordInput) { _, newValue in
                        // keyword 최대 글자수를 넘어가면, 최대글자수로 재설정
                        if newValue.count > viewModel.keywordMaxLength {
                            viewModel.currentKeywordInput = String(newValue.prefix(viewModel.keywordMaxLength))
                        }
                    }
                    .onSubmit(viewModel.addKeyword)
                    .font(.scoreDream(.medium, size: .body))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(keywordFocused.wrappedValue == .keyword ? Color.gray.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: keywordFocused.wrappedValue)
        }
        .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity), removal: .move(edge: .top).combined(with: .opacity)))
    }
    
    private var showWarningSection: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("중복된 키워드입니다.")
                .font(.scoreDream(.medium, size: .caption))
                .foregroundColor(.orange)
            Spacer()
        }
        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
    }
    
    private var keywordListSection: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(viewModel.keywords.enumerated()), id: \.element) { index, keyword in
                        KeywordChip(keyword: keyword) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.removeKeyword(keyword)
                            }
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal, 16)
            }
            .clipped()
            .onReceive(viewModel.$keywords) { keywords in
                // 새 키워드가 추가되면 스크롤을 맨 끝으로 이동
                if !keywords.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(keywords.count - 1, anchor: .trailing)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Keyword Chip
struct KeywordChip: View {
    let keyword: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text("#\(keyword)")
                .font(.scoreDream(.medium, size: .caption))
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}


#Preview {
    NavigationStack {
        StoryQuotesRecordView(
            book: Book(title: "", author: [], translator: [], introduction: "", publisher: "", publicationDate: "", bookImageURL: "", bookLink: "", ISBN: [], _id: ""))
        .environmentObject(BookStoriesViewModel())
    }
}
