//
//  FriendSearchBookStoriesView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/28/25.
//

import SwiftUI

struct FriendSearchBookStoriesView: View {
    
    // MARK: - Properties
    let friendId: String
    let keyword: String
    
    // MARK: - ViewModels
    @State private var searchViewModel: FriendSearchBookStoriesViewModel
    
    // MARK: - State
    @State private var selectedView: Int = 0  // 0: grid, 1: list
    
    // MARK: - Initialization
    init(friendId: String, keyword: String) {
        self.friendId = friendId
        self.keyword = keyword
        self._searchViewModel = State(
            initialValue: FriendSearchBookStoriesViewModel(friendId: friendId, keyword: keyword)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더 섹션
            headerSection
            
            // 탭 인디케이터
            TabIndicator(height: 3, selectedView: selectedView, tabCount: 2)
            
            // 컨텐츠 섹션
            contentSection
        }
        .navigationTitle("#\(keyword)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await searchViewModel.loadBookStories()
        }
        .refreshable {
            await searchViewModel.refreshBookStories()
        }
        .progressOverlay(
            viewModels: searchViewModel,
            opacity: false
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // 키워드 정보
            VStack(alignment: .leading, spacing: 8) {
                Text("친구의 '\(keyword)' 키워드")
                    .font(.appFont(.bold, size: .title2))
                    .foregroundColor(.primaryText)
                
                if !searchViewModel.isLoading {
                    Text("\(searchViewModel.bookStories.count)개의 북스토리")
                        .font(.appFont(.medium, size: .subheadline))
                        .foregroundColor(.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // 뷰 전환 버튼들
            ViewToggleButtons(selectedView: $selectedView)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.brownLeather.opacity(0.8),
                    Color.brownLeather.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            if selectedView == 0 {
                FriendSearchGridView(searchViewModel: searchViewModel)
            } else {
                FriendSearchListView(searchViewModel: searchViewModel)
            }
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .slide),
            removal: .opacity
        ))
    }
}

// MARK: - Grid View
struct FriendSearchGridView: View {
    @Bindable var searchViewModel: FriendSearchBookStoriesViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if searchViewModel.bookStories.isEmpty && !searchViewModel.isLoading {
                    searchEmptyStateView
                        .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(searchViewModel.bookStories, id: \.id) { story in
                            PublicStoryGridCard(story: story)
                                .task {
                                    await searchViewModel.loadMoreIfNeeded(currentItem: story)
                                }
                        }
                        
                        // 로딩 인디케이터
                        if !searchViewModel.isLastPage && searchViewModel.isLoading {
                            ForEach(0..<3, id: \.self) { _ in
                                LoadingGridCard()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var searchEmptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 50))
                .foregroundColor(.secondaryText.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("검색 결과가 없어요")
                    .font(.appFont(.bold, size: .title3))
                    .foregroundColor(.primaryText)
                
                Text("친구가 '\(searchViewModel.keyword)' 키워드를 사용한\n북스토리가 없습니다")
                    .font(.appFont(.medium, size: .subheadline))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
        .padding(.horizontal, 20)
    }
}

// MARK: - List View
struct FriendSearchListView: View {
    @Bindable var searchViewModel: FriendSearchBookStoriesViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if searchViewModel.bookStories.isEmpty && !searchViewModel.isLoading {
                    searchEmptyStateView
                } else {
                    VStack(spacing: 16) {
                        ForEach(searchViewModel.bookStories, id: \.id) { story in
                            PublicStoryListCard(story: story)
                                .task {
                                    await searchViewModel.loadMoreIfNeeded(currentItem: story)
                                }
                        }
                        
                        // 로딩 인디케이터
                        if !searchViewModel.isLastPage && searchViewModel.isLoading {
                            LoadingListCard()
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 40)
        }
    }
    
    private var searchEmptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 50))
                .foregroundColor(.secondaryText.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("검색 결과가 없어요")
                    .font(.appFont(.bold, size: .title3))
                    .foregroundColor(.primaryText)
                
                Text("친구가 '\(searchViewModel.keyword)' 키워드를 사용한\n북스토리가 없습니다")
                    .font(.appFont(.medium, size: .subheadline))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
        .padding(.horizontal, 20)
    }
}
