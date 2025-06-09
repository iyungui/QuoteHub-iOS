//
//  BookInfoCard.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI
import SDWebImageSwiftUI

/// 북스토리 - 선택한 책 정보
struct BookInfoCard: View {
    let book: Book
    
    var body: some View {
        VStack(spacing: 16) {
            CardHeader(title: "선택한 책", icon: "book.fill")
            
            HStack(spacing: 16) {
                WebImage(url: URL(string: book.bookImageURL))
                    .placeholder {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.paperBeige.opacity(0.3))
                            .overlay(
                                Image(systemName: "book.closed.fill")
                                    .foregroundColor(.brownLeather.opacity(0.7))
                                    .font(.title2)
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.antiqueGold.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .brownLeather.opacity(0.2), radius: 6, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.scoreDream(.bold, size: .subheadline))
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if !book.author.isEmpty {
                        Text(book.author.joined(separator: ", "))
                            .font(.scoreDream(.medium, size: .footnote))
                            .foregroundColor(.secondaryText)
                            .lineLimit(1)
                    }
                    
                    Text(book.publisher)
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(CardBackground())
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    BookInfoCard(book: Book(title: "코스모스", author: ["칼 세이건"], translator: [""], introduction: "", publisher: "", publicationDate: "", bookImageURL: "", bookLink: "", ISBN: [""], _id: ""))
}
