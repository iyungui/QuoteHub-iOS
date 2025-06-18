//  
//  SearchBookView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/09.
//

import SwiftUI

/// 북스토리 기록 1: 책검색 뷰 (책 검색, 결과 리스트 뷰 - 무한스크롤로 구현)
struct SearchBookView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    // viewmodel
    @State private var bookSearchViewModel = BookSearchViewModel()
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
            .progressOverlay(viewModel: bookSearchViewModel, animationName: "progressLottie", opacity: false)
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
                    .onSubmit {
                        performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        bookSearchViewModel.updateQuery("")
                        bookSearchViewModel.clearSearch()
                        
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
                    performSearch()
                }
            }) {
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.medium))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(bookSearchViewModel.isLoading ? Color.gray : Color.appAccent)
                    )
                    .adaptiveShadow(radius: 3, y: 2)
            }
            .disabled(bookSearchViewModel.isLoading)
            .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
        }
        .onSubmit {
            switch focusField {
            case .searchText:
                performSearch()
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
                if bookSearchViewModel.books.isEmpty && bookSearchViewModel.hasSearched && !bookSearchViewModel.isLoading {
                    
                    emptyStateView.padding(.top, 50)
                    
                } else {
                    ForEach(Array(bookSearchViewModel.books.enumerated()), id: \.element.id) { index, book in
                        BookSearchResultRowView(book: book)
                            .task {
                                // 마지막 책이 화면에 나타날 때
                                await bookSearchViewModel.loadMoreIfNeeded(currentIndex: index)
                            }
                    }
                    
                    if bookSearchViewModel.isLoadingMore {
                        loadingMoreView
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .refreshable {
            performSearch()
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
    
    private func performSearch() {
        print("performSearch 호출!")
        bookSearchViewModel.updateQuery(searchText)
        bookSearchViewModel.clearSearch()
        Task {
            await bookSearchViewModel.performSearchAsync()
        }
    }
}
