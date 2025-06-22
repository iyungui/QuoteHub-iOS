//
//  PublicThemeDetailView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct PublicThemeDetailView: View {
    
    // MARK: - Properties
    let theme: Theme
    
    // MARK: - ViewModels
    @State private var themeBookStoriesViewModel: PublicThemeBookStoriesViewModel
    
    // MARK: - State
    @State private var selectedView: Int = 0  // 0: grid, 1: list
    
    // MARK: - Initialization
    init(theme: Theme) {
        self.theme = theme
        self._themeBookStoriesViewModel = State(
            initialValue: PublicThemeBookStoriesViewModel(themeId: theme.id)
        )
    }
    
    var body: some View {
        ThemeDetailBaseView(
            theme: theme,
            selectedView: $selectedView,
            contentView: {
                PublicThemeContentView(
                    selectedView: selectedView,
                    themeBookStoriesViewModel: themeBookStoriesViewModel
                )
            },
            navigationBarItems: {
                EmptyView() // 공개 테마는 관리 버튼 없음
            }
        )
        .task {
            await themeBookStoriesViewModel.loadBookStories()
        }
        .refreshable {
            await themeBookStoriesViewModel.refreshBookStories()
        }
        .progressOverlay(
            viewModels: themeBookStoriesViewModel,
            opacity: true
        )
    }
}
