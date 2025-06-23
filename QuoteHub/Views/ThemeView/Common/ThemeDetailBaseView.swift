//
//  ThemeDetailBaseView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct ThemeDetailBaseView<ContentView: View, NavigationItems: View>: View {
    
    // MARK: - Properties
    let theme: Theme
    @Binding var selectedView: Int
    let contentView: () -> ContentView
    let navigationBarItems: () -> NavigationItems
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 테마 헤더
                    ThemeHeaderView(theme: theme, selectedView: $selectedView)
                        .id(theme.id + "_\(theme.updatedAt)")
                    
                    // 탭 인디케이터
                    TabIndicator(height: 3, selectedView: selectedView, tabCount: 2)
                    
                    // 컨텐츠 뷰
                    contentView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .slide),
                            removal: .opacity
                        ))
                }
            }
        }
        .navigationTitle(theme.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                navigationBarItems()
            }
        }
    }
}
