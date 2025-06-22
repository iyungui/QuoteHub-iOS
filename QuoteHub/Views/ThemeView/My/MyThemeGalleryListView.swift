//
//  MyThemeGalleryListView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct MyThemeGalleryListView: View {
    @Bindable var themeBookStoriesViewModel: MyThemeBookStoriesViewModel
    @Environment(UserViewModel.self) private var userViewModel
    
    var body: some View {
        LazyVStack(spacing: 0) {
            if themeBookStoriesViewModel.bookStories.isEmpty && !themeBookStoriesViewModel.isLoading {
                ThemeEmptyStateView(isMy: true, viewType: .list)
            } else {
                VStack(spacing: 16) {
                    ForEach(themeBookStoriesViewModel.bookStories, id: \.id) { story in
                        MyStoryListCard(story: story)
                            .task {
                                await themeBookStoriesViewModel.loadMoreIfNeeded(currentItem: story)
                            }
                    }
                    
                    // 로딩 인디케이터
                    if !themeBookStoriesViewModel.isLastPage && themeBookStoriesViewModel.isLoading {
                        LoadingListCard()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 40)
    }
}
