//
//  PublicThemesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/11/23.
//

import SwiftUI

/// 홈뷰에서 보이는 공개된 테마 리스트 뷰
struct PublicThemesListView: View {
    @Environment(PublicThemesViewModel.self) private var publicThemesViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(Array(publicThemesViewModel.themes.enumerated()), id: \.element.id) { index, theme in
                    ThemeView(
                        theme: theme,
                        index: index,
                        isCompact: false
                    )
                    .task {
                        await publicThemesViewModel.loadMoreIfNeeded(currentItem: theme)
                    }
                }
            }
            .frame(height: 200)
            .padding(.horizontal, 30)
        }
    }
}
