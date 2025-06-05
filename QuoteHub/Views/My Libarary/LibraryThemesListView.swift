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
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    private let spacing: CGFloat = 16
    
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(themesViewModel.themes(for: loadType), id: \.id) { theme in
                NavigationLink(
                    destination: ThemeDetailView(theme: theme, isMy: isMy)
                        .environmentObject(themesViewModel)
                        .environmentObject(userViewModel)
                ) {
                    LibThemeCard(theme: theme)
                }
                .buttonStyle(CardButtonStyle())
            }
            
            // 더 로딩할 테마가 있을 때 로딩 인디케이터
            if !themesViewModel.isLastPage {
                ForEach(0..<2, id: \.self) { _ in
                    loadingThemeCard
                }
                .onAppear {
                    themesViewModel.loadMoreIfNeeded(
                        currentItem: themesViewModel.themes(for: loadType).last,
                        type: loadType
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    /// loadMoreIfNeeded 호출 시 보여질 로딩  카드 (테마)
    private var loadingThemeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 이미지 placeholder
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.paperBeige.opacity(0.3))
                    .frame(width: 140, height: 140) // 실제 이미지와 동일한 크기
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.brownLeather)
                    )
                Spacer()
            }
            
            // 텍스트 placeholder
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.paperBeige.opacity(0.3))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.paperBeige.opacity(0.2))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 80) // 정보 영역과 동일한 높이
            .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity) // 그리드 공간을 균등하게 차지
        .frame(height: 260) // 실제 카드와 동일한 높이
        .padding(12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.antiqueGold.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - THEME CARD

struct LibThemeCard: View {
    let theme: Theme
    
    private var themeGradient: [Color] {
        let gradients: [[Color]] = [
            [.paperBeige, .brownLeather],
            [.antiqueGold, .paperBeige],
            [.brownLeather, Color.purple.opacity(0.7)],
            [Color.orange.opacity(0.8), Color.red.opacity(0.7)],
            [Color.teal.opacity(0.8), .antiqueGold],
            [.brownLeather, .antiqueGold]
        ]
        return gradients[abs(theme.id.hashValue) % gradients.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 테마 이미지
            HStack {
                Spacer()
                themeImageView
                Spacer()
            }
            
            // 테마 정보
            themeInfoView
        }
        .frame(maxWidth: .infinity) // 그리드 공간을 균등하게 차지
        .frame(height: 260) // 고정 높이 설정
        .padding(12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var themeImageView: some View {
        ZStack {
            // 배경 이미지
            WebImage(url: URL(string: theme.themeImageURL))
                .placeholder {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: themeGradient),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "folder.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("테마")
                                    .font(.scoreDream(.medium, size: .caption))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        )
                }
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 140) // 고정 크기 설정
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 140, height: 140) // 동일한 크기
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 공개/비공개 배지
            VStack {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: theme.isPublic ? "eye.fill" : "eye.slash.fill")
                            .font(.caption2)
                        Text(theme.isPublic ? "공개" : "비공개")
                            .font(.scoreDream(.medium, size: .caption2))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .padding(.top, 8)
                .padding(.trailing, 8)
                
                Spacer()
            }
        }
        .frame(width: 140, height: 140) // 전체 이미지 뷰 크기 고정
    }
    
    private var themeInfoView: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 테마 이름
            Text(theme.name)
                .font(.scoreDream(.bold, size: .subheadline))
                .foregroundColor(.primaryText)
                .lineLimit(1)
                .frame(height: 20, alignment: .leading) // 고정 높이
            
            // 테마 설명
            Text(theme.description.isEmpty ? " " : theme.description) // 빈 공간 유지
                .font(.scoreDream(.light, size: .caption))
                .foregroundColor(.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 32, alignment: .top) // 고정 높이 (2줄)
            
            Spacer() // 남은 공간 채우기
            
            // 생성일
            HStack {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(.brownLeather.opacity(0.7))
                
                Text(theme.createdAt.prefix(10))
                    .font(.scoreDream(.light, size: .caption2))
                    .foregroundColor(.secondaryText.opacity(0.8))
                
                Spacer()
                
                // 화살표 아이콘
                Image(systemName: "arrow.right.circle.fill")
                    .font(.caption)
                    .foregroundColor(.brownLeather.opacity(0.6))
            }
            .frame(height: 16) // 고정 높이
        }
        .frame(height: 80) // 전체 정보 영역 고정 높이
        .padding(.horizontal, 4)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.antiqueGold.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}
