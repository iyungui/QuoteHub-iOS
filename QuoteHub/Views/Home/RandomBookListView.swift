//
//  RandomBookListView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI
import SDWebImageSwiftUI

/// 홈뷰에서 쓰는 랜덤(최근에 검색된 책들중) 책 리스트 뷰
struct RandomBookListView: View {
    let randomBooks: [Book]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(randomBooks.enumerated()), id: \.element.id) { _, book in
                    
                    NavigationLink(destination: BookDetailView(book: book)
                    ) {
                        BookCard(book: book)
                    }
                    .buttonStyle(PlainButtonStyle())

                }
            }
            .padding(.horizontal, 30)
        }
    }
}

// MARK: - BOOK CARD VIEW

struct BookCard: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // 책 이미지
            bookImage
            bookInfo
        }
        .padding(.horizontal, 10)
        .scaleEffect(1.0)
    }
    
    private var bookImage: some View {
        WebImage(url: URL(string: book.bookImageURL))
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
            .frame(width: 120, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.antiqueGold.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: .brownLeather.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var bookInfo: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(book.title)
                .font(.scoreDream(.medium, size: .caption))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(.primaryText)
            
            Text(book.author.joined(separator: ", "))
                .font(.scoreDream(.light, size: .footnote))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(.secondaryText)
        }
        .frame(width: 140)
    }
}
