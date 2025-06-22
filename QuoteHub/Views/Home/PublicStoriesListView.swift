//
//  PublicStoriesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/9/23.
//

import SwiftUI

/// 홈뷰에서 보이는 공개된 북스토리 리스트 뷰
struct PublicStoriesListView: View {
    @Environment(PublicBookStoriesViewModel.self) private var publicBookStoriesViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(publicBookStoriesViewModel.bookStories, id: \.id) { story in
                    StoryView(story: story)
                    // 각 스토리가 보일 때마다 체크
                        .task {
                            await publicBookStoriesViewModel.loadMoreIfNeeded(currentItem: story)
                        }
                }
            }
            .padding(.horizontal, 30)
            .frame(height: 350)
        }
    }
}
