//
//  StoryListCardContent.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct StoryListCardContent: View {
    let story: BookStory
    
    var body: some View {
        HStack(spacing: 16) {
            // 이미지
            bookImageView
            
            // 컨텐츠
            VStack(alignment: .leading, spacing: 8) {
                // 인용문
                Text(story.firstQuoteText)
                    .font(.appFont(.medium, size: .footnote))
                    .foregroundColor(.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // 책 제목
                HStack(spacing: 6) {
                    Image(systemName: "book.closed.fill")
                        .font(.caption2)
                        .foregroundColor(.brownLeather.opacity(0.7))
                    
                    Text(story.bookId.title)
                        .font(.appFont(.medium, size: .caption))
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                }
                
                // 날짜와 키워드
                Text(story.createdAt.prefix(10))
                    .font(.appFont(.light, size: .caption2))
                    .foregroundColor(.secondaryText.opacity(0.8))
                
                if let keywords = story.keywords, !keywords.isEmpty {
                    KeywordTags(keywords: keywords)
                }
            }
            
            Spacer()
            
            // 화살표
            Image(systemName: "chevron.right")
                .font(.caption.weight(.medium))
                .foregroundColor(.secondaryText.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear,
                                    Color.antiqueGold.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var bookImageView: some View {
        WebImage(url: URL(string: story.bookId.bookImageURL))
            .resizable()
            .scaledToFill()
            .frame(width: 60, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.antiqueGold.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .brownLeather.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}
