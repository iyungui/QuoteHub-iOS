//
//  MyThemeDetailView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct MyThemeDetailView: View {
    
    // MARK: - Properties
    let theme: Theme
    
    // MARK: - ViewModels
    @Environment(MyThemesViewModel.self) private var myThemesViewModel
    @State private var themeBookStoriesViewModel: MyThemeBookStoriesViewModel
    @State private var themeDetailViewModel = ThemeDetailViewModel()

    // MARK: - State
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    init(theme: Theme) {
        self.theme = theme
        self._themeBookStoriesViewModel = State(
            initialValue: MyThemeBookStoriesViewModel(themeId: theme.id)
        )
    }
    
    var body: some View {
        Group {
            if let currentTheme = themeDetailViewModel.theme {
                ThemeDetailBaseView(
                    theme: currentTheme,
                    selectedView: $themeDetailViewModel.selectedView,
                    contentView: {
                        MyThemeContentView(
                            selectedView: themeDetailViewModel.selectedView,
                            themeBookStoriesViewModel: themeBookStoriesViewModel
                        )
                    },
                    navigationBarItems: {
                        MyThemeNavigationItems(showActionSheet: $themeDetailViewModel.showActionSheet)
                    }
                )
            } else if !themeDetailViewModel.isLoading {
                ContentUnavailableView("테마를 찾을 수 없습니다", systemImage: "folder.badge.questionmark")
            }
        }
        .confirmationDialog("테마 관리", isPresented: $themeDetailViewModel.showActionSheet, titleVisibility: .visible) {
            myThemeActionSheet
        }
        .fullScreenCover(
            isPresented: $themeDetailViewModel.isEditing,
            onDismiss: {
                themeDetailViewModel.loadThemeDetail(themeId: theme.id)
            }
        ) {
            NavigationStack {
                CreateThemeView(mode: .fullScreenSheet, themeId: theme.id)
            }
        }
        .alert("알림", isPresented: $themeDetailViewModel.showAlert) {
            Button("확인") { dismiss() }
        } message: {
            Text(themeDetailViewModel.alertMessage)
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
    
    @ViewBuilder
    private var myThemeActionSheet: some View {
        Button("수정하기") {
            themeDetailViewModel.isEditing = true
        }
        Button("삭제하기", role: .destructive) {
            Task { await deleteTheme() }
        }
        Button("취소", role: .cancel) { }
    }
    
    private func deleteTheme() async {
        let isSuccess = await myThemesViewModel.deleteTheme(themeId: theme.id)
        if isSuccess {
            themeDetailViewModel.showAlertWith(message: "테마가 성공적으로 삭제되었습니다.")
        } else {
            let errorMessage = myThemesViewModel.errorMessage ?? "테마 삭제 중 오류가 발생했습니다."
            themeDetailViewModel.showAlertWith(message: errorMessage)
        }
    }
}
