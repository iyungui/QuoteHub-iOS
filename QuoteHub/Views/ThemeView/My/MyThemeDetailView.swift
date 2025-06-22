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
    
    // MARK: - State
    @State private var selectedView: Int = 0  // 0: grid, 1: list
    @State private var showActionSheet = false
    @State private var isEditing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    init(theme: Theme) {
        self.theme = theme
        self._themeBookStoriesViewModel = State(
            initialValue: MyThemeBookStoriesViewModel(themeId: theme.id)
        )
    }
    
    var body: some View {
        ThemeDetailBaseView(
            theme: theme,
            selectedView: $selectedView,
            contentView: {
                MyThemeContentView(
                    selectedView: selectedView,
                    themeBookStoriesViewModel: themeBookStoriesViewModel
                )
            },
            navigationBarItems: {
                MyThemeNavigationItems(showActionSheet: $showActionSheet)
            }
        )
        .confirmationDialog("테마 관리", isPresented: $showActionSheet, titleVisibility: .visible) {
            myThemeActionSheet
        }
        .fullScreenCover(isPresented: $isEditing) {
            // ThemeEditView(theme: theme) { updatedTheme in
            //     isEditing = false
            // }
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인") {
                if alertMessage.contains("삭제") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
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
    
    @ViewBuilder
    private var myThemeActionSheet: some View {
        Button("수정하기") {
            isEditing = true
        }
        Button("삭제하기", role: .destructive) {
            Task { await deleteTheme() }
        }
        Button("취소", role: .cancel) { }
    }
    
    private func deleteTheme() async {
        let isSuccess = await myThemesViewModel.deleteTheme(themeId: theme.id)
        if isSuccess {
            alertMessage = "테마가 성공적으로 삭제되었습니다."
        } else {
            alertMessage = myThemesViewModel.errorMessage ?? "테마 삭제 중 오류가 발생했습니다."
        }
        showAlert = true
    }
}

