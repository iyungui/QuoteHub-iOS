//
//  PublicStoriesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/9/23.
//

import SwiftUI

/// 홈뷰에서 보이는 공개된 북스토리 리스트 뷰
struct PublicStoriesListView: View {
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(storiesViewModel.bookStories(for: .public), id: \.id) { story in
                    StoryView(story: story)
                }
                
                if !storiesViewModel.isLastPage {
                    loadingIndicator()
                }
            }
            .padding(.horizontal, 30)
            .frame(height: 350)
        }
    }
    
    private func loadingIndicator() -> some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.brownLeather)
            
            Text("더 불러오는 중...")
                .font(.scoreDream(.light, size: .caption))
                .foregroundColor(.secondaryText)
                .padding(.top, 8)
        }
        .frame(width: 100)
        .onAppear {
            storiesViewModel.loadMoreIfNeeded(
                currentItem: storiesViewModel.bookStories(for: .public).last,
                type: .public
            )
        }
    }
}
