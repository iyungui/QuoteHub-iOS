//
//  StoryBookView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/18/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct StoryBookView: View {
    let story: BookStory
    let cardSize: CGFloat
    @Environment(UserViewModel.self) private var userViewModel

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
    
    @ViewBuilder
    private var destinationView: some View {
        if story.userId.id == userViewModel.currentUser?.id {
            MyBookStoryDetailView(story: story)
        } else {
            PublicBookStoryDetailView(story: story)
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
                        Rectangle()
                            .fill(Color.paperBeige.opacity(0.3))
                            .overlay(
                                Image(systemName: "book.closed")
                                    .foregroundColor(.brownLeather)
                                    .font(.largeTitle)
                            )
                    }
                    .resizable()
                    .indicator(.activity)
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
