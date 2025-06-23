//
//  PublicBookStoryDetailView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

/// 다른 사람 북스토리 상세 뷰 (차단/신고 가능)
struct PublicBookStoryDetailView: View {
    
    // MARK: - Properties
    let story: BookStory
    
    // MARK: - ViewModels
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @Environment(BlockReportViewModel.self) private var blockReportViewModel
    @State private var detailViewModel = BookStoryDetailViewModel()
    @State private var commentViewModel: BookStoryCommentsViewModel
    
    init(story: BookStory) {
        self.story = story
        self._commentViewModel = State(wrappedValue: BookStoryCommentsViewModel(bookStoryId: story.id))
    }
    
    var body: some View {
        BookStoryDetailBaseView(
            detailViewModel: detailViewModel,
            commentViewModel: commentViewModel,
            contentView: { currentStory in
                BookStoryContentView(
                    story: currentStory,
                    detailViewModel: detailViewModel,
                    isMyStory: false
                )
            },
            actionSheetView: {
                publicStoryActionSheet
            },
            toolbarItems: {
                BookStoryToolbarItems(
                    detailViewModel: detailViewModel,
                    userAuthManager: userAuthManager
                )
            }
        )
        .task {
            await loadData()
        }
        .refreshable {
            await loadData()
        }
    }
    
    @ViewBuilder
    private var publicStoryActionSheet: some View {
        Button("차단하기") {
            Task { await blockUser() }
        }
        Button("신고하기") {
            detailViewModel.toggleReportSheet()
        }
        Button("취소", role: .cancel) { }
    }
    
    private func blockUser() async {
        let isSuccess = await blockReportViewModel.blockUser(story.userId.id)
        let alertMessage = isSuccess ? blockReportViewModel.successMessage : blockReportViewModel.errorMessage
        detailViewModel.showAlertWith(message: alertMessage ?? "")
    }
    
    private func loadData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await detailViewModel.loadStoryDetail(storyId: story.id)
            }
            group.addTask {
                await commentViewModel.loadCommentCount()
            }
        }
    }
}
