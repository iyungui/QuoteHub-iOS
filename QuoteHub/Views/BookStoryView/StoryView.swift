//
//  StoryView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - STORY VIEW

struct StoryView: View {
    let story: BookStory
    let isCompact: Bool  // 컴팩트 모드 (그리드용)
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    // 기본값으로 PublicStoriesListView와 동일하게 설정
    init(story: BookStory, isCompact: Bool = false, cardWidth: CGFloat = 280, cardHeight: CGFloat = 300) {
        self.story = story
        self.isCompact = isCompact
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
    }
    
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
        if story.userId.id == userViewModel.currentUser?.id {
            return AnyView(BookStoryDetailView(story: story, isMyStory: true)
                .environmentObject(userViewModel)
                .environmentObject(storiesViewModel)
                .environmentObject(userAuthManager))
        } else {
            return AnyView(BookStoryDetailView(story: story)
                .environmentObject(userViewModel)
                .environmentObject(storiesViewModel)
                .environmentObject(userAuthManager))
        }
    }

    private var newBadge: some View {
        HStack(spacing: isCompact ? 2 : 4) {
            Image(systemName: "sparkles")
                .font(.system(size: isCompact ? 8 : 10, weight: .bold))
            Text("NEW")
                .font(.scoreDream(.bold, size: isCompact ? 8 : 10))
        }
        .foregroundColor(.white)
        .padding(.horizontal, isCompact ? 6 : 8)
        .padding(.vertical, isCompact ? 3 : 4)
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
        .shadow(color: .black.opacity(0.2), radius: isCompact ? 2 : 4, x: 0, y: isCompact ? 1 : 2)
        .padding(.top, isCompact ? 8 : 12)
        .padding(.trailing, isCompact ? 8 : 12)
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
                                    .font(.system(size: isCompact ? 12 : 16))
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: isCompact ? 28 : 36, height: isCompact ? 28 : 36)
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
                    .frame(width: isCompact ? 28 : 36, height: isCompact ? 28 : 36)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.brownLeather.opacity(0.7))
                            .font(.system(size: isCompact ? 12 : 16, weight: .medium))
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
                    .frame(width: cardWidth, height: cardHeight)
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
    }
    
    private var quoteOverlay: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: isCompact ? 8 : 12) {
                // 문장
                HStack(alignment: .top, spacing: isCompact ? 6 : 8) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: isCompact ? 12 : 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 2)
                    
                    Text(story.firstQuoteText)
                        .font(.scoreDream(.medium, size: isCompact ? .footnote : .subheadline))
                        .lineLimit(isCompact ? 2 : 3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                }
                
                // 책 제목
                HStack {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: isCompact ? 10 : 12))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(story.bookId.title)
                        .font(.scoreDream(.regular, size: isCompact ? .caption2 : .caption))
                        .lineLimit(1)
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                }
                
                // 사용자 정보 (컴팩트 모드가 아닐 때만 표시)
                if !isCompact {
                    userInfoSection
                } else {
                    // 컴팩트 모드에서는 날짜만 표시
                    dateOnlySection
                }
            }
            .padding(.all, isCompact ? 12 : 20)
            .background(
                // 반투명 배경으로 가독성 향상
                RoundedRectangle(cornerRadius: isCompact ? 12 : 16)
                    .fill(Color.black.opacity(0.3))
                    .blur(radius: 1)
            )
            .padding(.bottom, 4)
        }
    }
    
    private var userInfoSection: some View {
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
                Text(story.createdAt.prefix(10))
                    .font(.scoreDream(.light, size: .footnote))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                
                Image(systemName: "book.pages")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    private var dateOnlySection: some View {
        HStack {
            Text(story.createdAt.prefix(10))
                .font(.scoreDream(.light, size: isCompact ? .caption2 : .footnote))
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            
            Spacer()
            
            Image(systemName: "book.pages")
                .font(.system(size: isCompact ? 8 : 12))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private func isRecentStory() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let storyDate = dateFormatter.date(from: String(story.createdAt.prefix(10))) else { return false }
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: storyDate, to: Date()).day ?? 0
        
        return daysSinceCreation <= 3 // 3일 이내는 NEW
    }
}
