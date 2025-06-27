//
//  FriendLibraryKeywordsView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/28/25.
//

import SwiftUI

struct FriendLibraryKeywordsView: View {
    
    // MARK: - Properties
    let friendId: String
    @Environment(FriendBookStoriesViewModel.self) private var friendBookStoriesViewModel
    
    // MARK: - ViewModels
    @State private var keywordsViewModel: FriendLibraryKeywordsViewModel?
    
    // MARK: - State
    @State private var showSortOptions = false
    @State private var selectedKeyword: String?
    @State private var showSearchView = false

    // MARK: - Grid Layout
    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 8)
    ]
    
    // MARK: - Initialization
    init(friendId: String) {
        self.friendId = friendId
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더 섹션
            headerSection
            
            // 컨텐츠 섹션
            contentSection
        }
        .navigationDestination(isPresented: $showSearchView) {
            if let keyword = selectedKeyword {
                FriendSearchBookStoriesView(friendId: friendId, keyword: keyword)
            }
        }
        .onAppear {
            setupViewModelIfNeeded()
        }
        .refreshable {
            keywordsViewModel?.refreshKeywords()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("친구 키워드")
                    .font(.scoreDream(.bold, size: .title3))
                    .foregroundColor(.primaryText)
                
                if let keywordsViewModel = keywordsViewModel {
                    Text("\(keywordsViewModel.keywords.count)개의 키워드")
                        .font(.scoreDream(.medium, size: .caption))
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            // 정렬 버튼
            if let keywordsViewModel = keywordsViewModel, !keywordsViewModel.keywords.isEmpty {
                sortButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var sortButton: some View {
        withAnimation(.none) {
            Button(action: {
                keywordsViewModel?.toggleSortOption()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: keywordsViewModel?.sortOption.systemImage ?? "textformat.abc")
                        .font(.caption)
                    Text(keywordsViewModel?.sortOption.title ?? "정렬")
                        .font(.scoreDream(.medium, size: .caption))
                }
                .foregroundColor(.brownLeather)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.brownLeather.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(Color.brownLeather.opacity(0.3), lineWidth: 1)
                        )
                )
            }}
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            if let keywordsViewModel = keywordsViewModel {
                if keywordsViewModel.keywords.isEmpty && !keywordsViewModel.isLoading {
                    emptyStateView
                } else {
                    keywordGridView(keywordsViewModel)
                }
            } else {
                // ViewModel이 아직 설정되지 않은 상태
                Color.clear
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "number.circle")
                .font(.system(size: 50))
                .foregroundColor(.secondaryText.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("키워드가 없어요")
                    .font(.scoreDream(.bold, size: .title3))
                    .foregroundColor(.primaryText)
                
                Text("친구가 아직 키워드를 사용한\n북스토리를 작성하지 않았어요")
                    .font(.scoreDream(.medium, size: .subheadline))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
        .padding(.horizontal, 20)
    }
    
    private func keywordGridView(_ viewModel: FriendLibraryKeywordsViewModel) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.keywords) { keywordInfo in
                    KeywordTagView(keywordInfo: keywordInfo) {
                        // 키워드 선택 시 네비게이션
                        selectedKeyword = keywordInfo.keyword
                        showSearchView = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Helper Methods
    private func setupViewModelIfNeeded() {
        if keywordsViewModel == nil {
            keywordsViewModel = FriendLibraryKeywordsViewModel(friendBookStoriesViewModel: friendBookStoriesViewModel)
        }
    }
}
