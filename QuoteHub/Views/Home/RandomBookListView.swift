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
    @EnvironmentObject private var booksViewModel: RandomBooksViewModel
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
//    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(booksViewModel.books.enumerated()), id: \.element.id) { _, book in
                    
                    NavigationLink(destination: BookDetailView(book: book)
                        .environmentObject(userAuthManager)
//                        .env YironmentObject(themesViewModel)
                        .environmentObject(storiesViewModel)
                    ) {
                        BookCard(book: book).environmentObject(booksViewModel)
                    }
                    .buttonStyle(PlainButtonStyle())

                }
            }
            .padding(.horizontal, 30)
        }
        // TODO: 메서드 확인
        .onAppear(perform: booksViewModel.getRandomBooksIfNeeded)
    }
}

// MARK: - BOOK CARD VIEW

struct BookCard: View {
    let book: Book
    @EnvironmentObject private var booksViewModel: RandomBooksViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // 책 이미지
            bookImage
            bookInfo
        }
        .padding(.horizontal, 10)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: booksViewModel.isLoading)
    }
    
    private var bookImage: some View {
        WebImage(url: URL(string: book.bookImageURL ?? ""))
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
            .transition(.fade(duration: 0.5))
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
            Text(book.title ?? "제목 없음")
                .font(.scoreDream(.medium, size: .caption))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(.primaryText)
            
            Text(book.author?.joined(separator: ", ") ?? "")
                .font(.scoreDream(.light, size: .footnote))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundColor(.secondaryText)
        }
        .frame(width: 140)
    }
}


#Preview {
    RandomBookListView()
}
