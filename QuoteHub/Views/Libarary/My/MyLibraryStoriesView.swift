//
//  MyLibraryStoriesView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

// MARK: - MY LIBRARY

/// 라이브러리 -> 북스토리 탭뷰에서 보이는 내 북스토리 리스트 뷰
struct MyLibraryStoriesView: View {
    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel

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
        return availableWidth / 3 // 3열 그리드
    }
    
    var body: some View {
        if myBookStoriesViewModel.bookStories.isEmpty {
            ContentUnavailableView {
                VStack {
                    Text("아직 기록이 없어요").font(.appHeadline)
                    Image(systemName: "tray")
                }
            } description: {
                Text("지금 바로 나만의 문장을 기록해보세요").font(.appBody)
            }

        } else {
            
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(myBookStoriesViewModel.bookStories, id: \.id) { story in
                    StoryBookView(story: story, cardSize: cardSize)
                    // 각 스토리가 보일 때마다 체크
                        .task {
                            await myBookStoriesViewModel.loadMoreIfNeeded(currentItem: story)
                        }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 8)
        }
    }
}
