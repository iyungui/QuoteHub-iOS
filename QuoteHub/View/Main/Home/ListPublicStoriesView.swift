//
//  ListPublicStoriesView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/9/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListPublicStoriesView: View {
    @ObservedObject var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(storiesViewModel.bookStories, id: \.id) { story in
                    StoryView(story: story).environmentObject(userViewModel)
                        .environmentObject(myStoriesViewModel)
                }
                if !storiesViewModel.isLastPage {
                    ProgressView()
                        .onAppear {
                            storiesViewModel.loadMoreIfNeeded(currentItem: storiesViewModel.bookStories.last)
                        }
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 320)
        }
    }
}

struct StoryView: View {
    let story: BookStory
    private let fixedHeight: CGFloat = 300
    private let infoContentHeight: CGFloat = 100 // Adjust this value as needed
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack(alignment: .bottom) {
                VStack {
                    storyImageView
                        .frame(height: fixedHeight - infoContentHeight)
                    Spacer(minLength: 0)
                }

                
                infoContentView
                    .frame(width: 180, height: infoContentHeight)
                    .background(Color(UIColor.secondarySystemBackground).opacity(0.85))
                    .cornerRadius(4)
            }
            .frame(width: 180, height: fixedHeight)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(4)
            .shadow(radius: 1)
            .padding(.horizontal, 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var destinationView: some View {
        if story.userId.id == userViewModel.user?.id {
            return AnyView(myBookStoryView(storyId: story.id).environmentObject(userViewModel).environmentObject(myStoriesViewModel))
        } else {
            return AnyView(friendBookStoryView(story: story))
        }
    }


    private var storyImageView: some View {
        WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }

    private var infoContentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(story.quote ?? "")
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
                .foregroundColor(.primary)

            Text(story.bookId.title)
                .font(.caption2)
                .fontWeight(.thin)
                .lineLimit(1)
                .foregroundColor(.secondary)

            HStack {
                if let url = URL(string: story.userId.profileImage), !story.userId.profileImage.isEmpty {
                    WebImage(url: url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 35)
                }


                VStack(alignment: .leading, spacing: 2) {
                    Text(story.userId.nickname)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text(story.userId.statusMessage ?? "")
                        .font(.caption2)
                        .fontWeight(.thin)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.horizontal, .bottom])
    }
}

