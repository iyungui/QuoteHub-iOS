//
//  ListStoryQuotesDisplayView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/13/25.
//

import SwiftUI

// MARK: - LIST QUOTES DISPLAY VIEW

struct ListStoryQuotesDisplayView: View {
    let story: BookStory
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(story.quotes.enumerated()), id: \.element.id) { index, quote in
                quoteItemCard(quote: quote, index: index)
            }
        }
        .padding(.top, 22)
    }

    private func quoteItemCard(quote: Quote, index: Int) -> some View {
        VStack(spacing: 0) {
            // 페이지 정보
            if let page = quote.page {
                HStack {
                    Text("p. \(page)")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Rectangle()
                        .fill(Color.paperBeige.opacity(0.3))
                )
            }
            
            // Quote 텍스트
            VStack(alignment: .leading, spacing: 8) {
                Text(quote.quote)
                    .font(.scoreDream(.light, size: .subheadline))
                    .foregroundColor(.primaryText)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color.lightPaper.opacity(0.1))
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 25)
    }
}
