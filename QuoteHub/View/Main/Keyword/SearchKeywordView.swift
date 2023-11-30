//
//  SearchKeywordView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/8/23.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - PUBLIC

struct SearchKeywordView: View {
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    @State private var searchKeyword: String
    @StateObject private var viewModel: BookStoriesViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @State private var isActioned: Bool = false

    init(searchKeyword: String = "") {
        self.searchKeyword = searchKeyword
        self._viewModel = StateObject(wrappedValue: BookStoriesViewModel(searchKeyword: searchKeyword, mode: .public))
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
                        StoryItemView(story: story).environmentObject(userViewModel)
                            .environmentObject(myStoriesViewModel).environmentObject(userAuthManager)
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

struct StoryItemView: View {
    let story: BookStory
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var userAuthManager: UserAuthenticationManager


    var body: some View {
        NavigationLink(destination: destinationView) {
            VStack {
                HStack {
                    storyImages
                    storyDetails
                    Spacer()
                }
                .padding(10)
                Divider()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var destinationView: some View {
        if story.userId.id == userViewModel.user?.id {
            return AnyView(myBookStoryView(storyId: story.id).environmentObject(userViewModel).environmentObject(myStoriesViewModel))
        } else {
            return AnyView(friendBookStoryView(story: story).environmentObject(userAuthManager))
        }
    }
    
    @ViewBuilder
    private var storyImages: some View {
        WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
            .placeholder {
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .frame(width: 80, height: 80)
            }
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.5))
            .scaledToFit()
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .padding(.trailing, 5)
    }
    
    
    @ViewBuilder
    private var storyDetails: some View {
        VStack(alignment: .leading, spacing: 5) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if let keywords = story.keywords, !keywords.isEmpty {
                        ForEach(keywords, id: \.self) { keyword in
                            Text("#\(keyword)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    } else {
                        Text("No Keywords")
                            .italic()
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            Text(story.bookId.title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(story.userId.nickname)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
