//
//  BookCaseView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/7/25.
//

import SwiftUI

#Preview {
    BookCaseView()
}

struct BookCaseView: View {
    let books: [EBook] = [
        EBook(coverImage: "book1"),
        EBook(coverImage: "book2"),
        EBook(coverImage: "book3"),
        EBook(coverImage: "book4"),
        EBook(coverImage: "book5"),
        EBook(coverImage: "book6"),
        EBook(coverImage: "book7"),
        EBook(coverImage: "book8"),
        EBook(coverImage: "book5"),
        EBook(coverImage: "book6"),
        EBook(coverImage: "book7"),
        EBook(coverImage: "book8")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("내 서재")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.inkBrown)
                    .padding(.top)
                
                ForEach(0..<numberOfShelves, id: \.self) { shelfIndex in
                    ShelfView(books: booksForShelf(shelfIndex))
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.lightPaper, Color.softBeige],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var numberOfShelves: Int {
        return (books.count + 2) / 3 // 3권씩 나누어 올림
    }
    
    private func booksForShelf(_ shelfIndex: Int) -> [EBook] {
        let startIndex = shelfIndex * 3
        let endIndex = min(startIndex + 3, books.count)
        return Array(books[startIndex..<endIndex])
    }
}

struct ShelfView: View {
    let books: [EBook]
    
    var body: some View {
        VStack(spacing: 0) {
            // 책들이 세워진 영역
            HStack(alignment: .bottom, spacing: 15) {
                ForEach(books.indices, id: \.self) { index in
                    EBookView(book: books[index])
                }
                
                // 빈 공간 채우기
                if books.count < 3 {
                    ForEach(0..<(3 - books.count), id: \.self) { _ in
                        Color.clear
                            .frame(width: 100, height: 150)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 2)
        }
    }
}

struct EBookView: View {
    let book: EBook
    
    var body: some View {
        Button(action: {
            print("책 선택: \(book.coverImage)")
        }) {
            ZStack {
                // 책 바닥 그림자 (더 사실적으로)
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
                            endRadius: 50
                        )
                    )
                    .frame(width: 90, height: 20)
                    .offset(x: 1, y: 76)
                    .blur(radius: 3)
                
                // 책 커버
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 100, height: 150)
                    .overlay(
                        // 실제 책 이미지
                        Image(book.coverImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 150)
                            .clipped()
                    )
                    .overlay(
                        Rectangle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 3, y: 2)
            }
        }
        .buttonStyle(BookButtonStyle())
    }
}


struct EBook {
    let coverImage: String
}

