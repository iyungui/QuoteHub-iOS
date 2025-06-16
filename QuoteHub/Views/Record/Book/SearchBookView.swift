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
    @Environment(\.dismiss) var dismiss
    
    // viewmodel
    @StateObject private var booksViewModel = BooksViewModel()
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
            VStack(spacing: 0) {
                searchField.padding()
                
                resultsListView
            }
            .bookPaperBackground()
            .navigationBarTitle("책 검색", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .progressOverlay(viewModel: booksViewModel, animationName: "progressLottie", opacity: false)
            .onAppear { setupSearchBinding() }
        }
    }

    var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "xmark")
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
    
    // MARK: - SEARCH FIELD
    
    private var searchField: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondaryText)
                    .font(.subheadline)
                
                TextField("제목이나 저자명을 입력하세요", text: $searchText)
                    .focused($focusField, equals: .searchText)
                    .submitLabel(.search)
                    .foregroundColor(.primaryText)
                    .onChange(of: searchText) { _, newValue in
                        booksViewModel.updateSearchQuery(newValue)
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        booksViewModel.clearSearch()
                        focusField = .searchText
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondaryText)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .adaptiveBackground()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .adaptiveShadow(radius: 2, y: 1)
            
            Button(action: {
                if searchText.isEmpty {
                    focusField = .searchText
                } else {
                    focusField = nil
                    booksViewModel.performSearch()
                }
            }) {
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.medium))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(booksViewModel.isLoading ? Color.gray : Color.appAccent)
                    )
                    .adaptiveShadow(radius: 3, y: 2)
            }
            .disabled(booksViewModel.isLoading)
            .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
        }
        .onSubmit {
            switch focusField {
            case .searchText:
                booksViewModel.performSearch()
                focusField = nil
            default:
                break
            }
        }
    }

    // result list view (책 검색 결과)
    private var resultsListView: some View {
        ScrollView {
            LazyVStack {
                if booksViewModel.books.isEmpty && booksViewModel.hasSearched && !booksViewModel.isLoading {
                    emptyStateView.padding(.top, 50)
                } else {
                    ForEach(Array(booksViewModel.books.enumerated()), id: \.element.id) { index, book in
                        BookRowView(book: book)
                            .environmentObject(booksViewModel)
                            .environmentObject(storiesViewModel)
                            .environmentObject(userAuthManager)
                            .onAppear {
                                // 마지막 책이 화면에 나타날 때
                                booksViewModel.loadMoreIfNeeded(currentIndex: index)
                            }
                    }
                    
                    if booksViewModel.isLoadingMore {
                        loadingMoreView
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .refreshable {
            /// pull to refresh 할 때는 async 메서드
            await booksViewModel.performSearchAsync()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color.secondaryText.opacity(0.6))
            
            VStack(spacing: 6) {
                Text("검색결과가 없습니다")
                    .font(.scoreDream(.medium, size: .title3))
                    .foregroundStyle(Color.primaryText)
                
                Text("다른 키워드로 검색해보세요")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .adaptiveBackground()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .adaptiveShadow(radius: 4, y: 2)
    }
    
    private var loadingMoreView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
                .tint(.appAccent)
            
            Text("더 많은 책을 불러오는 중...")
                .font(.scoreDream(.regular, size: .subheadline))
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .adaptiveBackground()
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .adaptiveShadow(radius: 2, y: 1)
    }
    
    private func setupSearchBinding() {
        booksViewModel.setupSearchDebouncing()
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
                .font(.scoreDream(.medium, size: .subheadline))
                .foregroundColor(.primaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if !book.author.isEmpty {
                Text(book.author.joined(separator: ", "))
                    .font(.scoreDream(.medium, size: .caption))
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
            }
            
            Text("출판사: \(book.publisher)")
                .font(.scoreDreamCaption)
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
