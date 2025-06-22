//
//  MyLibraryThemesView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI

// MARK: - MY LIBRARY
/// 라이브러리 -> 테마 탭뷰에서 보이는 내 테마 리스트 뷰
struct MyLibraryThemesView: View {
    @Environment(ThemesViewModel.self) private var themesViewModel

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    private let spacing: CGFloat = 16
    private let horizontalPadding: CGFloat = 20
    
    // UIScreen 방법 - GeometryReader 없이 화면 크기 계산
    private var cardSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - (horizontalPadding * 2) - spacing
        return availableWidth / 2 // 2열 그리드, 정사각형
    }
    
    var body: some View {
        if themesViewModel.themes(for: .my).isEmpty {
            ContentUnavailableView(
                "아직 테마가 없어요",
                systemImage: "tray",
                description: Text("지금 바로 나만의 테마를 만들어보세요")
            )
        } else {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(Array(themesViewModel.themes(for: .my).enumerated()), id: \.element.id) { index, theme in
                    ThemeView(
                        theme: theme,
                        index: index,
                        isCompact: true,
                        cardWidth: cardSize,
                        cardHeight: cardSize
                    )
                    .task {
                        themesViewModel.loadMoreIfNeeded(
                            currentItem: theme,
                            type: .my
                        )
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 8)
        }
    }
}
