//
//  CarouselStoryQuotesDisplayView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/13/25.
//

import SwiftUI

// MARK: - CAROUSEL QUOTES DISPLAY VIEW

struct CarouselStoryQuotesDisplayView: View {
    let story: BookStory
    
    let width: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(Array(story.quotes.enumerated()), id: \.element.id) { index, quote in
                    quoteDisplayCard(quote: quote, index: index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .contentMargins(32)
        .frame(height: width - 20)
    }
    
    private func quoteDisplayCard(quote: Quote, index: Int) -> some View {
        VStack(spacing: 0) {
            // 페이지 정보 헤더
            HStack {
                if let page = quote.page {
                    Text("p. \(page)")
                        .font(.appFont(.regular, size: .caption))
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                // 현재 quotes 총 페이지 수 표시
                Text("\(index + 1) / \(story.quotes.count)")
                    .font(.appFont(.light, size: .caption))
                    .foregroundColor(.secondaryText.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Rectangle()
                    .fill(Color.paperBeige.opacity(0.3))
            )
            
            // Quote 텍스트
            ScrollView {
                Text(quote.quote)
                    .font(.appFont(.light, size: .subheadline))
                    .foregroundColor(.primaryText)
                    .lineSpacing(12)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .background(Color.lightPaper.opacity(0.1))
        }
        .containerRelativeFrame(.horizontal)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
