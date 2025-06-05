//
//  PublicThemesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/11/23.
//

import SwiftUI
import SDWebImageSwiftUI

/// 홈뷰에서 보이는 공개된 테마 리스트 뷰
struct PublicThemesListView: View {
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(Array(themesViewModel.themes(for: .public).enumerated()), id: \.element.id) { index, theme in
                    ThemeView(
                        theme: theme,
                        index: index
                    )
                    .environmentObject(themesViewModel)
                    .environmentObject(userViewModel)
                }
                
                if !themesViewModel.isLastPage {
                    loadingIndicator()
                }
            }
            .frame(height: 200)
            .padding(.horizontal, 30)
        }
    }
    
    private func loadingIndicator() -> some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.brownLeather)
            
            Text("테마 더 불러오는 중...")
                .font(.scoreDream(.light, size: .caption))
                .foregroundColor(.secondaryText)
                .padding(.top, 8)
        }
        .frame(width: 120)
        .onAppear {
            themesViewModel.loadMoreIfNeeded(
                currentItem: themesViewModel.themes(for: .public).last,
                type: .public
            )
        }
    }
}
