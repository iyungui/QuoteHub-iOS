//  
//  SearchBookView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/09.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchBookView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = BooksViewModel()
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel

    
    @State private var searchText: String = ""
    
    enum Field: Hashable {
        case searchText
    }
    @FocusState private var focusField: Field?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                searchField
                Group {
                    resultsListView
                }
            }
            .padding()
            .navigationBarTitle("책 검색", displayMode: .inline)
            .navigationBarItems(leading: backButton)
            .onAppear {
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
    
    private func searchBook() {
        viewModel.books.removeAll()
        viewModel.resetCurrentPage()
        viewModel.isEnd = false
        viewModel.fetchBooks(query: searchText)
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

    private var resultsListView: some View {
        ScrollView {
            LazyVStack {
                if viewModel.books.isEmpty && viewModel.hasSearched {
                    Text("검색결과가 없습니다.")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.top)
                } else {
                    ForEach(Array(viewModel.books.enumerated()), id: \.element.id) { index, book in
                        bookItemView(book: book).environmentObject(viewModel).environmentObject(myStoriesViewModel)
                            .onAppear {
                                // 마지막 책이 화면에 나타날 때
                                if index == viewModel.books.count - 1 && !viewModel.isEnd {
                                    // 추가 데이터 로드
                                    viewModel.fetchBooks(query: searchText)
                                }
                            }
                    }
                }
            }
        }
    }
}

struct bookItemView: View {
    var book: Book
    @EnvironmentObject var viewModel: BooksViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel


    var body: some View {
        NavigationLink(destination: (BookDetailView(book: book)).environmentObject(myStoriesViewModel)) {
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
