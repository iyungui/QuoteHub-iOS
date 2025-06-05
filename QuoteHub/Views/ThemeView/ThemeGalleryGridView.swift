//
//  ThemeGalleryGridView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - THEME GALLERY GRID VIEW

struct ThemeGalleryGridView: View {
    let isMy: Bool
    let loadType: LoadType
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel

    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 3) {
            ForEach(storiesViewModel.bookStories(for: loadType), id: \.id) { story in
                NavigationLink(
                    destination: BookStoryDetailView(story: story, isMyStory: isMy)
                        .environmentObject(storiesViewModel)
                        .environmentObject(userViewModel)
                ) {
                    WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                        .clipped()
                }
            }
            if !storiesViewModel.isLastPage {
                ProgressView().onAppear {
                    storiesViewModel.loadMoreIfNeeded(
                        currentItem: storiesViewModel.bookStories(for: loadType).last,
                        type: loadType
                    )
                }
            }
        }
    }
}


#Preview {
    ThemeGalleryGridView(isMy: true, loadType: .my)
}
