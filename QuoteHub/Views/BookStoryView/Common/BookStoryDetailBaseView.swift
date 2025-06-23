//
//  BookStoryDetailBaseView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct BookStoryDetailBaseView<ContentView: View, ActionSheet: View, ToolbarItems: View>: View {
    
    // MARK: - Properties
    @Bindable var detailViewModel: BookStoryDetailViewModel
    @Bindable var commentViewModel: BookStoryCommentsViewModel
    let contentView: (BookStory) -> ContentView
    let actionSheetView: () -> ActionSheet
    let toolbarItems: () -> ToolbarItems
    
    var body: some View {
        Group {
            if let currentStory = detailViewModel.story {
                contentView(currentStory)
                    .sheet(isPresented: $detailViewModel.showReportSheet) {
                        ReportSheetView(targetId: currentStory.id, reportType: .bookstory)
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                    }
            } else if detailViewModel.isLoading == false {
                ContentUnavailableView("북스토리를 찾을 수 없습니다", systemImage: "book.closed.fill")
            }
        }
        .backgroundGradient()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("북스토리")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                toolbarItems()
            }
        }
        .confirmationDialog(Text(""), isPresented: $detailViewModel.showActionSheet) {
            actionSheetView()
        }
        .alert("알림", isPresented: $detailViewModel.showAlert) {
            Button(role: .cancel) {} label: { Text("확인") }
        } message: {
            Text(detailViewModel.alertMessage)
        }
        .sheet(isPresented: $detailViewModel.isCommentSheetExpanded) {
            CommentView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .progressOverlay(viewModels: detailViewModel, opacity: false)
        .environment(detailViewModel)
        .environment(commentViewModel)
    }
}
