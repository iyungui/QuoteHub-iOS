//
//  BookSearchResultRowView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/18/25.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - BOOK ROW VIEW

struct BookSearchResultRowView: View {
    var book: Book
    
    var body: some View {
        NavigationLink(
            destination: BookDetailView(book: book)
        ) {
            HStack(spacing: 16) {
                bookImageView
                bookInfoView
                Spacer()
                chevronIcon
            }
            .padding(16)
            .adaptiveBackground()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .adaptiveShadow(radius: 6, y: 3)
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var bookImageView: some View {
        WebImage(url: URL(string: book.bookImageURL))
            .placeholder {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondaryCardBackground)
                    .overlay(
                        Image(systemName: "book.fill")
                            .font(.title2)
                            .foregroundColor(.secondaryText.opacity(0.6))
                    )
            }
            .resizable()
            .indicator(.activity)
            .scaledToFit()
            .frame(width: 80, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .adaptiveShadow(radius: 4, y: 2)
    }
    
    private var bookInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(book.title)
                .font(.appFont(.medium, size: .subheadline))
                .foregroundColor(.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if !book.author.isEmpty {
                Text(book.author.joined(separator: ", "))
                    .font(.appFont(.medium, size: .caption))
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
            }
            
            Text("출판사: \(book.publisher)")
                .font(.appCaption)
                .foregroundColor(.secondaryText.opacity(0.8))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.caption.weight(.medium))
            .foregroundColor(.secondaryText.opacity(0.6))
    }
}
