//
//  LibraryThemesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI

/// 라이브러리 -> 테마 탭뷰에서 보이는 테마 리스트 뷰
struct LibraryThemesListView: View {
    let isMy: Bool
    let loadType: LoadType
    
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
    
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(Array(themesViewModel.themes(for: loadType).enumerated()), id: \.element.id) { index, theme in
                ThemeView(
                    theme: theme,
                    index: index,
                    isCompact: true, // 컴팩트 모드 (유저정보 숨김 + 폰트 작게)
                    cardWidth: cardSize,
                    cardHeight: cardSize // 정사각형
                )
            }
            
            // 더 로딩할 테마가 있을 때 로딩 인디케이터
            if !themesViewModel.isLastPage {
                ForEach(0..<2, id: \.self) { _ in
                    loadingThemeCard(size: cardSize)
                }
                .onAppear {
                    themesViewModel.loadMoreIfNeeded(
                        currentItem: themesViewModel.themes(for: loadType).last,
                        type: loadType
                    )
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 8)
    }
    
    /// loadMoreIfNeeded 호출 시 보여질 로딩 카드 (테마)
    private func loadingThemeCard(size: CGFloat) -> some View {
        ZStack {
            // 배경 placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.paperBeige.opacity(0.3),
                            Color.antiqueGold.opacity(0.2),
                            Color.brownLeather.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.brownLeather)
                )
            
            // 하단 텍스트 placeholder 오버레이
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.8))
                            .frame(height: 12)
                            .frame(maxWidth: size * 0.7, alignment: .leading)
                        
                        Spacer()
                        
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 12, height: 12)
                    }
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.6))
                        .frame(height: 8)
                        .frame(maxWidth: size * 0.5, alignment: .leading)
                    
                    HStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.5))
                            .frame(height: 6)
                            .frame(maxWidth: size * 0.3, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .frame(width: size, height: size) // 정사각형
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
