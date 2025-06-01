//
//  PublicStoriesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/9/23.
//

import SwiftUI
import SDWebImageSwiftUI

/// 홈뷰에서 보이는 공개된 북스토리 리스트 뷰
struct PublicStoriesListView: View {
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
//    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @EnvironmentObject private var userViewModel: UserViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(storiesViewModel.bookStories, id: \.id) { story in
                    StoryView(story: story)
                        .environmentObject(userViewModel)
                        .environmentObject(storiesViewModel)
                        .environmentObject(userAuthManager)
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
            storiesViewModel.loadMoreIfNeeded(currentItem: storiesViewModel.bookStories.last)
        }
    }
}

// MARK: - BOOK STORY VIEW

struct StoryView: View {
    let story: BookStory
    private let cardWidth: CGFloat = 280
    private let cardHeight: CGFloat = 300
    private let imageHeight: CGFloat = 200
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @EnvironmentObject private var userViewModel: UserViewModel

    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack {
                backgroundSection
                
                quoteOverlay
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.antiqueGold.opacity(0.6), Color.brownLeather.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.2), value: story.id)
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var destinationView: some View {
        if story.userId.id == userViewModel.user?.id {
            return AnyView(BookStoryDetailView(story: story, isMyStory: true)
                .environmentObject(userViewModel)
                .environmentObject(storiesViewModel))
                .environmentObject(userAuthManager)
        } else {
            return AnyView(BookStoryDetailView(story: story)
                .environmentObject(userViewModel)
                .environmentObject(storiesViewModel))
                .environmentObject(userAuthManager)
        }
    }

    private var newBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .bold))
            Text("NEW")
                .font(.scoreDream(.bold, size: 10))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange.opacity(0.9), Color.red.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding(.top, 12)
        .padding(.trailing, 12)
    }
    
    private var profileImage: some View {
        Group {
            if let url = URL(string: story.userId.profileImage), !story.userId.profileImage.isEmpty {
                WebImage(url: url)
                    .placeholder {
                        Circle()
                            .fill(Color.paperBeige.opacity(0.5))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.brownLeather.opacity(0.7))
                                    .font(.system(size: 16))
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
            } else {
                // 대체 이미지
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.paperBeige.opacity(0.8), Color.antiqueGold.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.brownLeather.opacity(0.7))
                            .font(.system(size: 16, weight: .medium))
                    )
            }
        }
    }
    
    private var backgroundSection: some View {
        Group {
            if let imageUrl = story.storyImageURLs?.first, !imageUrl.isEmpty {
                // 이미지가 있는 경우
                WebImage(url: URL(string: imageUrl))
                    .placeholder {
                        gradientBackground
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardHeight)
            } else {
                // 이미지가 없는 경우
                gradientBackground
            }
        }
        .overlay(
            // 텍스트 가독성을 위해
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            // NEW 배지 (최근 글인 경우)
            Group {
                if isRecentStory() {
                    newBadge
                }
            },
            alignment: .topTrailing
        )
    }
    
    private var gradientBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.paperBeige.opacity(0.8),
                Color.antiqueGold.opacity(0.6),
                Color.brownLeather.opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            VStack {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.8))
                Text("텍스트 중심 스토리")
                    .font(.scoreDream(.light, size: .caption))
                    .foregroundColor(.white.opacity(0.9))
            }
        )
    }
    
    private var quoteOverlay: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                // 인용구
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 2)
                    
                    Text(story.quote ?? "")
                        .font(.scoreDream(.medium, size: .subheadline))
                        .lineLimit(3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                
                // 책 제목
                HStack {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(story.bookId.title)
                        .font(.scoreDream(.regular, size: .caption))
                        .lineLimit(1)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                }
                
                // 사용자 정보
                HStack(spacing: 12) {
                    // 프로필 이미지
                    profileImage
                    
                    // 사용자 정보
                    VStack(alignment: .leading, spacing: 2) {
                        Text(story.userId.nickname)
                            .font(.scoreDream(.medium, size: .caption))
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)

                        Text(story.userId.statusMessage ?? "")
                            .font(.scoreDream(.light, size: .footnote))
                            .lineLimit(1)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                    }
                    
                    Spacer()
                    
                    // 날짜 정보
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(story.createdAtDate)
                            .font(.scoreDream(.light, size: .footnote))
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                        
                        Image(systemName: "book.pages")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding(.all, 20)
            .background(
                // 반투명 배경으로 가독성 향상
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.3))
                    .blur(radius: 1)
            )
            .padding(.bottom, 4)
        }
    }
    
    private var dateInfo: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(story.createdAtDate)
                .font(.scoreDream(.light, size: .footnote))
                .foregroundColor(.secondaryText)
            
            // 책 아이콘
            Image(systemName: "book.pages")
                .font(.system(size: 10))
                .foregroundColor(Color.antiqueGold.opacity(0.7))
        }
    }
    
    private func isRecentStory() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let storyDate = dateFormatter.date(from: story.createdAtDate) else { return false }
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: storyDate, to: Date()).day ?? 0
        
        return daysSinceCreation <= 3 // 3일 이내는 NEW
    }
}

