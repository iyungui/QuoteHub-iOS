//
//  BookDetailView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/01.
//

import SwiftUI
import SDWebImageSwiftUI

struct BookDetailView: View {
    let book: Book
    @State private var navigateToRecordView = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    @State private var showAlert: Bool = false
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel


    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 15) {
                bookImage
                bookTitle
                Divider()
                bookDetails
                Divider()
                if userAuthManager.isUserAuthenticated {
                    actionButtons
                    Divider()
                } else {
                    EmptyView()
                }
                sourceCredit
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
             Alert(
                 title: Text("외부 사이트로 이동"),
                 message: Text("이 책에 대한 추가 정보를 외부 사이트에서 제공합니다. 외부 링크를 통해 해당 정보를 보시겠습니까?"),
                 primaryButton: .default(Text("확인")) {
                     if let url = URL(string: book.bookLink ?? "") {
                         UIApplication.shared.open(url)
                     }
                 },
                 secondaryButton: .cancel()
             )
         }
    }

    private var bookImage: some View {
        Group {
            if let imageUrl = book.bookImageURL, !imageUrl.isEmpty {
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.clear)
                    }
                    .indicator(.activity)
                    .scaledToFit()
                    .frame(width: 100, height: 140)
                    .padding(.vertical)
                    .shadow(color: Color.black.opacity(0.9), radius: 2, x: 0, y: 5)
            } else {
                Image(systemName: "book.closed.circle")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: 100, height: 140)
                    .padding(.vertical)
            }
        }
    }
    private var bookTitle: some View {
        Text(book.title ?? "No title")
            .font(.title2)
            .fontWeight(.heavy)
            .padding(.horizontal)
    }

    private var bookDetails: some View {
        VStack(alignment: .leading, spacing: 15) {
            detailRow(label: "저자", value: book.author?.joined(separator: ", ") ?? "")
            if !(book.translator?.isEmpty ?? true) {
                detailRow(label: "옮긴이", value: book.translator?.joined(separator: ", ") ?? "정보 없음")
            }
            detailRow(label: "출판사", value: book.publisher ?? "출판사 정보 없음")
            Text(book.introduction ?? "정보 없음")
                .font(.subheadline)
                .lineLimit(6)
                .padding(.vertical, 15)
            detailRow(label: "ISBN", value: book.ISBN?.joined(separator: ", ") ?? "", isFootnote: true)
            detailRow(label: "출판일", value: book.publicationDatePrefix ?? "", isFootnote: true)
        }
        .padding(10)
    }

    private func detailRow(label: String, value: String, isFootnote: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(isFootnote ? .footnote : .subheadline)
            Text(value)
                .font(isFootnote ? .footnote : .subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isFootnote ? .gray : .primary)
        }
    }

    private var actionButtons: some View {
        HStack {
            externalLinkButton
            Divider()
            recordLinkButton
        }
    }

    private var externalLinkButton: some View {
        Button(action: {
            self.showAlert = true
        }) {
            HStack{
                Image(systemName: "doc.text.magnifyingglass")
                Text("도서 정보 보기")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .buttonStyle(MyActionButtonStyle())
    }

    private var recordLinkButton: some View {
        NavigationLink(destination: RecordView(book: book).environmentObject(myStoriesViewModel), isActive: $navigateToRecordView) {
            Button(action: {
                navigateToRecordView = true
            }) {
                HStack {
                    Text("북스토리 기록")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Image(systemName: "highlighter")
                }
            }
            .buttonStyle(MyActionButtonStyle())
        }
    }

    private var sourceCredit: some View {
        HStack {
            Spacer()
            Text("출처: 카카오")
                .padding(.trailing)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

