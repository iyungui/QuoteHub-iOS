//
//  FriendLibraryThemesView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct FriendLibraryThemesView: View {
    let friendId: String
    @Environment(FriendThemesViewModel.self) private var friendThemesViewModel
    
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
    
    var body: some View {
        if friendThemesViewModel.themes.isEmpty {
            ContentUnavailableView(
                "",
                systemImage: "tray",
                description: Text("공개된 테마가 없습니다").font(.appBody)
            )
        } else {
            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(Array(friendThemesViewModel.themes.enumerated()), id: \.element.id) { index, theme in
                    ThemeView(
                        theme: theme,
                        index: index,
                        isCompact: true,
                        cardWidth: cardSize,
                        cardHeight: cardSize
                    )
                    .task {
                        await friendThemesViewModel.loadMoreIfNeeded(currentItem: theme)
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 8)
        }
    }
}
