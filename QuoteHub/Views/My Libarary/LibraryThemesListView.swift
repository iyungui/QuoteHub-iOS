//
//  LibraryThemesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI
import SDWebImageSwiftUI

/// 라이브러리 -> 테마 탭뷰에서 보이는 테마 리스트 뷰
struct LibraryThemesListView: View {
    let isMy: Bool
    let loadType: LoadType
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 20
    
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
//    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(themesViewModel.themes(for: loadType), id: \.id) { theme in
                NavigationLink(
                    destination: ThemeDetailView(theme: theme, isMy: isMy)
                        .environmentObject(themesViewModel)
                        .environmentObject(userViewModel)
//                        .environmentObject(storiesViewModel)
                ) {
                    LibThemeRowView(theme: theme)
                }
            }
            if !themesViewModel.isLastPage {
                ProgressView().onAppear {
                    themesViewModel.loadMoreIfNeeded(
                        currentItem: themesViewModel.themes(for: loadType).last,
                        type: loadType
                    )
                }
            }
        }
        .padding(.all, spacing)
    }
}

// MARK: - THEME ROW VIEW

struct LibThemeRowView: View {
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading) {
            if let url = URL(string: theme.themeImageURL), !theme.themeImageURL.isEmpty {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: (UIScreen.main.bounds.width / 2) - 35, height: (UIScreen.main.bounds.width / 2) - 35)
                    .cornerRadius(8)
                    .clipped()
                    .shadow(radius: 4)
                
            } else {
                Color.gray
                    .frame(width: (UIScreen.main.bounds.width / 2) - 35, height: (UIScreen.main.bounds.width / 2) - 35)
                    .cornerRadius(8)
                    .clipped()
                    .shadow(radius: 4)
            }
            
            Text(theme.name)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top, 5)
        }
        .padding(.horizontal, 10)
        .padding(.bottom)
    }
}

