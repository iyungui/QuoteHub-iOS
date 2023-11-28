//
//  FriendSearchKeywordView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/13/23.
//

import SwiftUI

// MARK: - FRIEND

struct FriendSearchKeywordView: View {
    let friendId: User

    @State private var searchKeyword: String
    @StateObject private var viewModel: BookStoriesViewModel
    @State private var isActioned: Bool = false

    init(searchKeyword: String = "", friendId: User) {
        self.searchKeyword = searchKeyword
        self.friendId = friendId
        self._viewModel = StateObject(wrappedValue: BookStoriesViewModel(searchKeyword: searchKeyword, mode: .friendStories(friendId.id)))
    }
    
    enum Field: Hashable {
        case searchKeyword
    }

    @FocusState private var focusField: Field?
    
    var body: some View {
        VStack(spacing: 20) {
            searchField
            Group {
                resultsListView
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("키워드 검색", displayMode: .inline)
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
    }
    
    private func searchWithKeyword() {
        self.isActioned = true

        viewModel.updateSearchKeyword(searchKeyword)
        viewModel.refreshBookStories()
    }
    
    private var searchField: some View {
        VStack(spacing: 15) {

            HStack {
                TextField("키워드를 입력하세요", text: $searchKeyword)
                    .focused($focusField, equals: .searchKeyword)
                    .submitLabel(.done)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        searchWithKeyword()
                    }
                
                Button(action: {
                    searchWithKeyword()
                }) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
    }
    
    private var resultsListView: some View {
        ScrollView {
            LazyVStack {
                if viewModel.bookStories.isEmpty && isActioned {
                    Text("검색결과가 없습니다.")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.top)
                } else {
                    ForEach(viewModel.bookStories, id: \.id) { story in
                        MyStoryItemView(story: story)
                    }
                    if !viewModel.isLastPage && isActioned {
                        ProgressView()
                            .onAppear {
                                viewModel.loadMoreIfNeeded(currentItem: viewModel.bookStories.last)
                            }
                    }
                }
            }
        }
    }
}
