//
//  LibraryStoriesListView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI
import SDWebImageSwiftUI

/// 라이브러리 -> 북스토리 탭뷰에서 보이는 북스토리 리스트 뷰
struct LibraryStoriesListView: View {
    let isMy: Bool
    let loadType: LoadType
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    
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
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(storiesViewModel.bookStories(for: loadType), id: \.id) { story in
                StoryView(
                    story: story,
                    isCompact: true, // 그리드 모드는 컴팩트
                    cardWidth: cardSize,
                    cardHeight: cardSize // 정사각형
                )
                .environmentObject(storiesViewModel)
                .environmentObject(userViewModel)
                .environmentObject(userAuthManager)
            }
            
            // 더 로딩할 스토리가 있을 때 로딩 인디케이터
            if !storiesViewModel.isLastPage {
                ForEach(0..<2, id: \.self) { _ in
                    loadingStoryCard(size: cardSize)
                }
                .onAppear {
                    storiesViewModel.loadMoreIfNeeded(
                        currentItem: storiesViewModel.bookStories(for: loadType).last,
                        type: loadType
                    )
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, 8)
    }
    
    private func loadingStoryCard(size: CGFloat) -> some View {
        ZStack {
            // 배경 placeholder
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.paperBeige.opacity(0.3))
                .overlay(
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.brownLeather)
                )
            
            // 하단 정보 placeholder 오버레이
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    // 인용문 placeholder
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.8))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.6))
                                .frame(height: 6)
                                .frame(maxWidth: size * 0.6, alignment: .leading)
                        }
                    }
                    
                    // 책 제목과 날짜 placeholder
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 3) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 6, height: 6)
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.7))
                                    .frame(height: 6)
                                    .frame(maxWidth: size * 0.4, alignment: .leading)
                            }
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.5))
                                .frame(height: 5)
                                .frame(maxWidth: size * 0.3, alignment: .leading)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
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
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}
