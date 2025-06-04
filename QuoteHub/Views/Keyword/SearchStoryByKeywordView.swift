//
//  SearchStoryByKeywordView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/13/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchStoryByKeywordView: View {
    @State private var searchKeyword: String
    
    let type: LoadType
    
    @StateObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager

    init(searchKeyword: String = "", type: LoadType) {
        self.searchKeyword = searchKeyword
        self.type = type
        self._storiesViewModel = StateObject(wrappedValue: BookStoriesViewModel(searchKeyword: searchKeyword))
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
        storiesViewModel.updateSearchKeyword(searchKeyword)
//        storiesViewModel.refreshBookStories(type: type) // TODO: - 이거 맞는지 확인.
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
                if storiesViewModel.bookStories(for: type).isEmpty {
                    Text("검색결과가 없습니다.")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding(.top)
                } else {
                    ForEach(storiesViewModel.bookStories(for: type), id: \.id) { story in
                        StoryRowInSearchKeyword(story: story, type: type)
                            .environmentObject(storiesViewModel)
                            .environmentObject(userViewModel)
                    }
                    if !storiesViewModel.isLastPage {
                        ProgressView()
                            .onAppear {
                                storiesViewModel.loadMoreIfNeeded(
                                    currentItem: storiesViewModel.bookStories(for: type).last,
                                    type: type
                                )
                            }
                    }
                }
            }
        }
    }
}

// MARK: - STOEY ROW IN SEARCH KEYWORD

struct StoryRowInSearchKeyword: View {
    let story: BookStory
    let type: LoadType
    var isMy: Bool {
        if type == .my {
            return true
        }
        return false
    }
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        NavigationLink(
            destination: BookStoryDetailView(story: story, isMyStory: isMy)
                .environmentObject(storiesViewModel)
                .environmentObject(userViewModel)
        ) {
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
