//
//  LibraryContentSection.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct LibraryContentSection<StoriesView: View, ThemesView: View, KeywordView: View>: View {
    let selectedTab: LibraryTab
    let storiesView: () -> StoriesView
    let themesView: () -> ThemesView
    let keywordsView: () -> KeywordView?
    
    var body: some View {
        switch selectedTab {
        case .stories:
            storiesView()
        case .themes:
            themesView()
        case .keywords:
            // TODO: 키워드 뷰 추가
            keywordsView()
        }
    }
}
