//
//  LibraryContentSection.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct LibraryContentSection<StoriesView: View, ThemesView: View>: View {
    let selectedTab: LibraryTab
    let storiesView: () -> StoriesView
    let themesView: () -> ThemesView
    
    var body: some View {
        switch selectedTab {
        case .stories:
            storiesView()
        case .themes:
            themesView()
        case .keywords:
            // TODO: 키워드 뷰 추가
            ContentUnavailableView(
                "준비 중인 기능입니다",
                systemImage: "hammer",
                description: Text("키워드별 북스토리 기능을 준비 중입니다")
            )
        }
    }
}
