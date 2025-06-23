//
//  MyBookStoryDetailView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

/// 내 북스토리 상세 뷰 (삭제, 수정 가능)
struct MyBookStoryDetailView: View {
    
    // MARK: - Properties
    let story: BookStory
    
    // MARK: - ViewModels
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel
    @Environment(BlockReportViewModel.self) private var blockReportViewModel
    @State private var detailViewModel = BookStoryDetailViewModel()
    @State private var commentViewModel: BookStoryCommentsViewModel
    
    // MARK: - State
    @Environment(\.dismiss) var dismiss
    
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
                    isMyStory: true
                )
            },
            actionSheetView: {
                myStoryActionSheet
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
    private var myStoryActionSheet: some View {
        NavigationLink {
            StoryQuotesRecordView(book: story.bookId, storyId: story.id)
        } label: {
            Text("수정하기")
        }
        
        Button("삭제하기", role: .destructive) {
            Task {
                let isSuccess = await myBookStoriesViewModel.deleteBookStory(storyId: story.id)
                if isSuccess {
                    dismiss()
                } else {
                    detailViewModel.showAlertWith(message: "북스토리를 삭제하지 못했습니다.")
                }
            }
        }
        
        Button("취소", role: .cancel) { }
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
