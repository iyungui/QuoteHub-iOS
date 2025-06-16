//
//  LibraryStoriesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI
import SDWebImageSwiftUI

/// 라이브러리 -> 북스토리 탭뷰에서 보이는 북스토리 리스트 뷰
struct LibraryStoriesListView: View {
    let isMy: Bool
    let loadType: LoadType
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    
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
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(storiesViewModel.bookStories(for: loadType), id: \.id) { story in
                StoryBookView(story: story, cardSize: cardSize)
                    .environmentObject(storiesViewModel)
                    .environmentObject(userViewModel)
                    .environmentObject(userAuthManager)
            }
            
            // 더 로딩할 스토리가 있을 때 로딩 인디케이터
            if !storiesViewModel.isLastPage {
                ForEach(0..<3, id: \.self) { _ in // 3열이므로 3개
                    loadingStoryCard(size: cardSize)
                }
                .onAppear {
                    storiesViewModel.loadMoreIfNeeded(
                        currentItem: storiesViewModel.bookStories(for: loadType).last,
                        type: loadType
                    )
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 8)
    }
    
    /// 스토리(책 이미지) 로딩 뷰
    private func loadingStoryCard(size: CGFloat) -> some View {
        let aspectRatio: CGFloat = 1.5 // 높이가 너비의 1.5배 (책 비율)
        let cardHeight = size * aspectRatio
        let bookWidth = size * 0.85
        let bookHeight = bookWidth * aspectRatio
        
        return ZStack {
            // 은은한 책장
            bookshelf(width: size, bookBottom: cardHeight * 0.45)
            
            // 책 바닥 그림자 (로딩용)
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.15),
                            Color.black.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: bookWidth * 0.5
                    )
                )
                .frame(width: bookWidth * 0.9, height: size * 0.2)
                .offset(x: size * 0.01, y: cardHeight * 0.35)
                .blur(radius: 3)
            
            // 책 커버 placeholder
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.paperBeige.opacity(0.3))
                .overlay(
                    ProgressView()
                        .scaleEffect(1.0)
                        .tint(.brownLeather)
                )
                .frame(width: bookWidth, height: bookHeight)
                .shadow(color: .black.opacity(0.2), radius: size * 0.06, x: size * 0.03, y: size * 0.02)
        }
        .frame(width: size, height: cardHeight)
    }
    
    // 은은한 책장
    private func bookshelf(width: CGFloat, bookBottom: CGFloat) -> some View {
        ZStack {
            // 책장 선반 (메인)
            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.brownLeather.opacity(0.5),
                            Color.brownLeather.opacity(0.3),
                            Color.brownLeather.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.95, height: width * 0.04)
                .offset(y: bookBottom)
            
            // 책장 깊이감 (뒤쪽 면)
            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.inkBrown.opacity(0.12),
                            Color.inkBrown.opacity(0.06)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.92, height: width * 0.02)
                .offset(x: width * 0.008, y: bookBottom + width * 0.01)
                .blur(radius: 0.5)
            
            // 책장 모서리 하이라이트
            Rectangle()
                .fill(Color.antiqueGold.opacity(0.15))
                .frame(width: width * 0.95, height: 0.5)
                .offset(y: bookBottom - width * 0.018)
        }
    }
}

struct StoryBookView: View {
    let story: BookStory
    let cardSize: CGFloat
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @EnvironmentObject private var userViewModel: UserViewModel
    
    private let aspectRatio: CGFloat = 1.5 // 책의 높이/너비 비율
    
    private var cardHeight: CGFloat {
        cardSize * aspectRatio
    }
    
    private var bookWidth: CGFloat {
        cardSize * 0.85 // 카드 크기의 85%
    }
    
    private var bookHeight: CGFloat {
        bookWidth * aspectRatio
    }
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack {
                // 은은한 책장
                bookshelf(width: cardSize, bookBottom: cardHeight * 0.45)
                
                // 책 바닥 그림자
                backgroundShadow
                
                // 책 커버
                bookCoverImage
            }
            .frame(width: cardSize, height: cardHeight)
        }
        .buttonStyle(BookButtonStyle())
    }
    
    private var destinationView: some View {
        if story.userId.id == userViewModel.user?.id {
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
    
    private var backgroundShadow: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                RadialGradient(
                    colors: [
                        Color.black.opacity(0.25),
                        Color.black.opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 2,
                    endRadius: bookWidth * 0.5
                )
            )
            .frame(width: bookWidth * 0.9, height: cardSize * 0.2)
            .offset(x: cardSize * 0.01, y: cardHeight * 0.35)
            .blur(radius: 2)
    }
    
    private var bookCoverImage: some View {
        Group {
            if let url = URL(string: story.bookId.bookImageURL), !story.bookId.bookImageURL.isEmpty {
                WebImage(url: url)
                    .placeholder {
                        Circle()
                            .fill(Color.paperBeige.opacity(0.5))
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: bookWidth, height: bookHeight)
                    .clipped()
                    .shadow(color: .black.opacity(0.3), radius: cardSize * 0.06, x: cardSize * 0.03, y: cardSize * 0.02)
            } else {
                Rectangle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: bookWidth, height: bookHeight)
            }
        }
    }
    
    // 은은한 책장 만들기
    private func bookshelf(width: CGFloat, bookBottom: CGFloat) -> some View {
        ZStack {
            // 책장 선반 (메인)
            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.brownLeather.opacity(0.5),
                            Color.brownLeather.opacity(0.3),
                            Color.brownLeather.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.95, height: width * 0.04)
                .offset(y: bookBottom)
            
            // 책장 깊이감 (뒤쪽 면)
            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.inkBrown.opacity(0.12),
                            Color.inkBrown.opacity(0.06)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: width * 0.92, height: width * 0.02)
                .offset(x: width * 0.008, y: bookBottom + width * 0.01)
                .blur(radius: 0.5)
            
            // 책장 모서리 하이라이트
            Rectangle()
                .fill(Color.antiqueGold.opacity(0.15))
                .frame(width: width * 0.95, height: 0.5)
                .offset(y: bookBottom - width * 0.018)
        }
    }
}

