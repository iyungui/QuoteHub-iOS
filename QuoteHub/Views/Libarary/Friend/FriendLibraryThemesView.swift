//
//  FriendLibraryThemesView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct FriendLibraryThemesView: View {
    let friendId: String
    @Environment(ThemesViewModel.self) private var themesViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private let spacing: CGFloat = 16
    private let horizontalPadding: CGFloat = 20
    
    private var cardSize: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - (horizontalPadding * 2) - spacing
        return availableWidth / 2
    }
    
    private var loadType: LoadType {
        .friend(friendId)
    }
    
    var body: some View {
        if themesViewModel.themes(for: loadType).isEmpty {
            ContentUnavailableView(
                "아직 테마가 없어요",
                systemImage: "tray",
                description: Text("공개된 테마가 없습니다")
            )
        } else {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(Array(themesViewModel.themes(for: loadType).enumerated()), id: \.element.id) { index, theme in
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
                            type: loadType
                        )
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 8)
        }
    }
}
