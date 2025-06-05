//
//  ThemeGalleryListView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - THEME GALLERY LIST VIEW

struct ThemeGalleryListView: View {
    let isMy: Bool
    let loadType: LoadType
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(storiesViewModel.bookStories(for: loadType), id: \.id) { story in
                NavigationLink(
                    destination: BookStoryDetailView(story: story, isMyStory: isMy)
                        .environmentObject(storiesViewModel)
                        .environmentObject(userViewModel)
                ) {
                    HStack {
                        Text(story.quote ?? "")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                        WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 85, height: 85)
                            .clipped()
                    }
                    .padding(10)
                    .padding(.horizontal, 10)
                }
                Divider()
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
        .padding(.top)
    }
}
