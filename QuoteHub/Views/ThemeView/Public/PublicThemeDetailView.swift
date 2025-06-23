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
    @State private var themeDetailViewModel = ThemeDetailViewModel()

    // MARK: - State
    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization
    init(theme: Theme) {
        self.theme = theme
        self._themeBookStoriesViewModel = State(
            initialValue: PublicThemeBookStoriesViewModel(themeId: theme.id)
        )
    }
    
    var body: some View {
        Group {
            if let currentTheme = themeDetailViewModel.theme {
                ThemeDetailBaseView(
                    theme: currentTheme,
                    selectedView: $themeDetailViewModel.selectedView,
                    contentView: {
                        PublicThemeContentView(
                            selectedView: themeDetailViewModel.selectedView,
                            themeBookStoriesViewModel: themeBookStoriesViewModel
                        )
                    },
                    navigationBarItems: {
                        EmptyView() // 공개 테마는 관리 버튼 없음
                    }
                )
            } else if !themeDetailViewModel.isLoading {
                ContentUnavailableView("테마를 찾을 수 없습니다", systemImage: "folder.badge.questionmark")

            }
        }
        .task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await themeBookStoriesViewModel.loadBookStories()
                }
                group.addTask {
                    await themeDetailViewModel.loadThemeDetail(themeId: theme.id)
                }
            }
        }
        .refreshable {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await themeBookStoriesViewModel.refreshBookStories()
                }
                group.addTask {
                    await themeDetailViewModel.loadThemeDetail(themeId: theme.id)
                }
            }
        }
        .progressOverlay(
            viewModels: themeBookStoriesViewModel,
            opacity: false
        )
    }
}
