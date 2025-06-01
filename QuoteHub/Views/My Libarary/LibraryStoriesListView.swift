//
//  LibraryStoriesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct LibraryStoriesListView: View {
    let isMy: Bool
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private let spacing: CGFloat = 20
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(storiesViewModel.bookStories, id: \.id) { story in
                NavigationLink(
                    destination: BookStoryDetailView(story: story, isMyStory: isMy)
                        .environmentObject(storiesViewModel)
                        .environmentObject(userViewModel)
                        .environmentObject(userAuthManager)
                ) {
                    LibStoryRowView(story: story)
                }
            }
            
            if !storiesViewModel.isLastPage {
                ProgressView().onAppear {
                    storiesViewModel.loadMoreIfNeeded(currentItem: storiesViewModel.bookStories.last)
                }
            }
        }
        .padding(.all, 20)
    }
}


struct LibStoryRowView: View {
    let story: BookStory
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: (UIScreen.main.bounds.width / 2) - 60, height: (UIScreen.main.bounds.width / 2) - 20)
                .cornerRadius(4)
                .clipped()
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.25), lineWidth: 1))
            
            Text(story.quote ?? "")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(story.content ?? "")
                .font(.subheadline)
            
            Text(story.keywords?.prefix(2).map { "#\($0)" }.joined(separator: " ") ?? "")
                .font(.caption)
                .foregroundColor(.blue)
                .lineLimit(2) // 텍스트 줄 수 제한
        }
        .frame(width: (UIScreen.main.bounds.width / 2) - 60, height: 250)
        .padding(.all, 15)
        .background(Color(.systemBackground))
        .cornerRadius(4)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3), lineWidth: 1))
        .buttonStyle(PlainButtonStyle())

    }
}
