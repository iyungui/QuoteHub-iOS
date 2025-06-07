//
//  KeywordGroupedStoriesView.swift
//  QuoteHub
//
//  Created by Assistant
//

import SwiftUI
import SDWebImageSwiftUI

struct KeywordGroupedStoriesView: View {
    let isMy: Bool
    let loadType: LoadType
    
    @State private var searchKeyword: String = ""
    @State private var showSearchField: Bool = false
    @State private var groupedStories: [String: [BookStory]] = [:]
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    enum Field: Hashable {
        case searchKeyword
    }
    
    @FocusState private var focusField: Field?
    
    var body: some View {
        VStack(spacing: 15) {
            // 검색 토글 버튼
            searchToggleButton
            
            // 검색창
            if showSearchField {
                searchField
            }
            
            // 키워드별 그룹화된 스토리 리스트
            keywordGroupedList
        }
        .padding(.horizontal, 20)
        .onAppear {
            groupStoriesByKeywords()
        }
        .onChange(of: storiesViewModel.bookStories(for: loadType)) { _, _ in
            groupStoriesByKeywords()
        }
    }
    
    // MARK: - Private Views
    
    private var searchToggleButton: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSearchField.toggle()
                    if !showSearchField {
                        searchKeyword = ""
                        groupStoriesByKeywords() // 검색 초기화 시 전체 목록 다시 로드
                    }
                }
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.subheadline)
                    Text(showSearchField ? "검색 닫기" : "키워드 검색").font(.scoreDream(.regular, size: .subheadline))
                }
                .foregroundColor(.secondaryText)
            }
            Spacer()
        }
    }
    
    private var searchField: some View {
        HStack {
            TextField("키워드를 입력하세요", text: $searchKeyword)
                .focused($focusField, equals: .searchKeyword)
                .submitLabel(.search)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    searchWithKeyword()
                }
            
            Button(action: {
                searchWithKeyword()
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondaryText)
            }
            
            if searchKeyword.isEmpty {
                Button(action: {
                    searchKeyword = ""
                    groupStoriesByKeywords()
                    focusField = .searchKeyword
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondaryText)
                }
            }
            
        }
        .transition(.opacity)
    }
    
    private var keywordGroupedList: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            if groupedStories.isEmpty {
                ContentUnavailableView(
                    "해당 키워드가 있는 스토리가 없어요",
                    systemImage: "tag",
                    description: Text("스토리에 \(searchKeyword)키워드를 추가해보세요")
                )
            } else {
                ForEach(Array(groupedStories.keys.sorted()), id: \.self) { keyword in
                    KeywordGroupView(
                        keyword: keyword,
                        stories: groupedStories[keyword] ?? [],
                        isMy: isMy
                    )
                    .environmentObject(storiesViewModel)
                    .environmentObject(userViewModel)
                    
                    Divider()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func searchWithKeyword() {
        let trimmedKeyword = searchKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedKeyword.isEmpty {
            groupStoriesByKeywords()
        } else {
            filterStoriesByKeyword(trimmedKeyword)
        }
    }
    
    private func groupStoriesByKeywords() {
        let stories = storiesViewModel.bookStories(for: loadType)
        var grouped: [String: [BookStory]] = [:]
        
        for story in stories {
            if let keywords = story.keywords, !keywords.isEmpty {
                for keyword in keywords {
                    if grouped[keyword] == nil {
                        grouped[keyword] = []
                    }
                    grouped[keyword]?.append(story)
                }
            }
        }
        
        groupedStories = grouped
    }
    
    private func filterStoriesByKeyword(_ keyword: String) {
        let stories = storiesViewModel.bookStories(for: loadType)
        var filtered: [String: [BookStory]] = [:]
        
        for story in stories {
            if let keywords = story.keywords {
                let matchingKeywords = keywords.filter { $0.localizedCaseInsensitiveContains(keyword) }
                
                for matchingKeyword in matchingKeywords {
                    if filtered[matchingKeyword] == nil {
                        filtered[matchingKeyword] = []
                    }
                    filtered[matchingKeyword]?.append(story)
                }
            }
        }
        
        groupedStories = filtered
    }
}

// MARK: - Keyword Group View

struct KeywordGroupView: View {
    let keyword: String
    let stories: [BookStory]
    let isMy: Bool
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 키워드 헤더
            HStack {
                Text("#\(keyword)")
                    .font(.scoreDream(.medium, size: .footnote))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.appAccent.opacity(0.1))
                    )
                
                Text("\(stories.count)개")
                    .font(.scoreDream(.thin, size: .caption2))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // 해당 키워드의 스토리들
            LazyVStack(spacing: 8) {
                ForEach(stories, id: \.id) { story in
                    KeywordStoryRow(story: story, isMy: isMy)
                        .environmentObject(storiesViewModel)
                        .environmentObject(userViewModel)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

// MARK: - Keyword Story Row

struct KeywordStoryRow: View {
    let story: BookStory
    let isMy: Bool
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        NavigationLink(
            destination: BookStoryDetailView(story: story, isMyStory: isMy)
                .environmentObject(storiesViewModel)
                .environmentObject(userViewModel)
        ) {
            HStack(spacing: 12) {
                // 책 이미지
                WebImage(url: URL(string: story.bookId.bookImageURL))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .cornerRadius(6)
                    .clipped()
                
                // 책 정보
                VStack(alignment: .leading, spacing: 2) {
                    Text(story.bookId.title)
                        .font(.scoreDream(.medium, size: .subheadline))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !story.bookId.author.isEmpty {
                        Text(story.bookId.author.first!)
                            .font(.scoreDreamCaption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // 화살표
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.7))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
