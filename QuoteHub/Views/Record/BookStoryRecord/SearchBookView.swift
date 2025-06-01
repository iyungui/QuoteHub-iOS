//  
//  SearchBookView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/09.
//

import SwiftUI
import SDWebImageSwiftUI

/// 북스토리 기록 1: 책검색 뷰 (책 검색, 결과 리스트 뷰 - 무한스크롤로 구현)
struct SearchBookView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    // viewmodel
    @StateObject var booksViewModel = BooksViewModel()
    @EnvironmentObject var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    @State private var searchText: String = ""
    
    // focusField
    enum Field: Hashable {
        case searchText
    }
    @FocusState private var focusField: Field?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                searchField
                Group {
                    resultsListView
                }
            }
            .padding()
            .navigationBarTitle("책 검색", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .onAppear {
                // TODO: - 이 부분 수정 (삭제)
                UITextField.appearance().clearButtonMode = .whileEditing
            }
        }
    }

    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
    
    private var searchField: some View {
        HStack {
            TextField("제목이나 저자명을 입력하세요", text: $searchText)
                .focused($focusField, equals: .searchText)
                .submitLabel(.done)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                if searchText.isEmpty {
                    focusField = .searchText
                } else {
                    focusField = nil
                    searchBook()
                }
            }) {
                Image(systemName: "magnifyingglass")
            }
        }
        .onSubmit {
            switch focusField {
            case .searchText:
                searchBook()
            default:
                break
            }
        }
    }

    // result list view (책 검색 결과)
    private var resultsListView: some View {
        ScrollView {
            LazyVStack {
                if booksViewModel.books.isEmpty && booksViewModel.hasSearched {
                    ContentUnavailableView("", systemImage: "books.vertical.fill", description: Text("검색결과가 없습니다."))
                } else {
                    ForEach(Array(booksViewModel.books.enumerated()), id: \.element.id) { index, book in
                        BookRowView(book: book)
                            .environmentObject(booksViewModel)
                            .environmentObject(storiesViewModel)
                            .environmentObject(userAuthManager)
                            .onAppear {
                                // 마지막 책이 화면에 나타날 때
                                if index == booksViewModel.books.count - 1 && !booksViewModel.isEnd {
                                    // 추가 데이터 로드
                                    booksViewModel.fetchBooks(query: searchText)
                                }
                            }
                    }
                }
            }
        }
    }
    
    private func searchBook() {
        booksViewModel.books.removeAll()
        booksViewModel.resetCurrentPage()
        booksViewModel.isEnd = false
        booksViewModel.fetchBooks(query: searchText)
    }
}

// MARK: - BOOK ROW VIEW

struct BookRowView: View {
    var book: Book
    
    @EnvironmentObject private var booksViewModel: BooksViewModel
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    
    var body: some View {
        NavigationLink(
            destination: BookDetailView(book: book)
                .environmentObject(storiesViewModel)
                .environmentObject(userAuthManager)
        ) {
            HStack {
                if let imageUrl = book.bookImageURL, !imageUrl.isEmpty {
                    WebImage(url: URL(string: imageUrl))
                        .placeholder {
                            Rectangle().foregroundColor(.clear)
                        }
                        .resizable()
                        .indicator(.activity)
                        .scaledToFit()
                        .frame(width: 80, height: 100)
                        .padding(.trailing)
                } else {
                    Image(systemName: "book.closed.circle")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 80, height: 100)
                        .padding(.trailing)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(book.title ?? "제목 없음").font(.subheadline)
                    Text(book.author?.joined(separator: ", ") ?? "").font(.footnote).foregroundColor(.gray)
                    Text("출판사: \(book.publisher ?? "출판사 정보 없음")").font(.footnote).foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(10)
            .buttonStyle(PlainButtonStyle())
        }
        Divider()
    }
}
