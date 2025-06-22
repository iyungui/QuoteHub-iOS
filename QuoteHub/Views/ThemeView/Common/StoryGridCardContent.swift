//
//  StoryGridCardContent.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct StoryGridCardContent: View {
    let story: BookStory
    
    var body: some View {
        ZStack {
            // 이미지 또는 기본 배경
            if let imageUrls = story.storyImageURLs,
               let imageUrl = imageUrls.first,
               !imageUrl.isEmpty {
                WebImage(url: URL(string: imageUrl))
                    .placeholder {
                        defaultBackground
                    }
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
            } else {
                defaultBackground
                    .aspectRatio(1, contentMode: .fill)
            }
            
            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.6)
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // 텍스트 오버레이
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(story.firstQuoteText)
                        .font(.scoreDream(.medium, size: .caption2))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    
                    Text(story.bookId.title)
                        .font(.scoreDream(.light, size: .caption2))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
            }
        }
        .clipShape(Rectangle())
        .overlay(
            Rectangle()
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
    }
    
    private var defaultBackground: some View {
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
            VStack(spacing: 4) {
                Image(systemName: "quote.opening")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        )
    }
}

