//
//  FriendLibraryStoriesView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI


// MARK: - FRIEND LIBRARY

struct FriendLibraryStoriesView: View {
    @Bindable var friendBookStoriesViewModel: FriendBookStoriesViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private let spacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 20
    
    private var cardSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - (horizontalPadding * 2) - (spacing * 2)
        return availableWidth / 3
    }

    var body: some View {
        if friendBookStoriesViewModel.bookStories.isEmpty {
            ContentUnavailableView(
                "아직 기록이 없어요",
                systemImage: "tray",
                description: Text("공개된 북스토리가 없습니다")
            )
        } else {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(friendBookStoriesViewModel.bookStories, id: \.id) { story in
                    StoryBookView(story: story, cardSize: cardSize)
                        .task {
                            await friendBookStoriesViewModel.loadMoreIfNeeded(currentItem: story)
                        }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 8)
        }
    }
}
