//
//  PublicThemeGalleryGridView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct PublicThemeGalleryGridView: View {
    @Bindable var themeBookStoriesViewModel: PublicThemeBookStoriesViewModel
    @Environment(UserViewModel.self) private var userViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    
    var body: some View {
        LazyVStack(spacing: 0) {
            if themeBookStoriesViewModel.bookStories.isEmpty && !themeBookStoriesViewModel.isLoading {
                ThemeEmptyStateView(isMy: false, viewType: .grid)
                    .padding(.top, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(themeBookStoriesViewModel.bookStories, id: \.id) { story in
                        PublicStoryGridCard(story: story)
                            .task {
                                await themeBookStoriesViewModel.loadMoreIfNeeded(currentItem: story)
                            }
                    }
                    
                    // 로딩 인디케이터
                    if !themeBookStoriesViewModel.isLastPage && themeBookStoriesViewModel.isLoading {
                        ForEach(0..<3, id: \.self) { _ in
                            LoadingGridCard()
                        }
                    }
                }
            }
        }
    }
}
