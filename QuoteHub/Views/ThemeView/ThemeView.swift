//
//  ThemeView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - THEME VIEW (범용)

struct ThemeView: View {
    let theme: Theme
    let index: Int
    let isCompact: Bool  // 컴팩트 모드 (그리드용)
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    // 기본값으로 PublicThemesListView와 동일하게 설정
    init(theme: Theme, index: Int = 0, isCompact: Bool = false, cardWidth: CGFloat = 240, cardHeight: CGFloat = 180) {
        self.theme = theme
        self.index = index
        self.isCompact = isCompact
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
    }
    
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
//    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
//    @EnvironmentObject private var userAuthManager: UserAuthenticationManager

    private var themeGradient: [Color] {
        let gradients: [[Color]] = [
            [.paperBeige, .brownLeather],
            [.antiqueGold, .paperBeige],
            [.brownLeather, Color.purple.opacity(0.7)],
            [Color.orange.opacity(0.8), Color.red.opacity(0.7)],
            [Color.teal.opacity(0.8), .antiqueGold],
            [.brownLeather, .antiqueGold]
        ]
        return gradients[index % gradients.count]
    }
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack {
                // 배경 이미지
                backgroundImage
                
                // 그라데이션 오버레이
                gradientOverlay
                
                // 컨텐츠
                contentView
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var backgroundImage: some View {
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
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: cardWidth, height: cardHeight)
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                Color.clear,
                themeGradient[0].opacity(0.7),
                themeGradient[1].opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var contentView: some View {
        VStack {
            // 상단 사용자 정보 (컴팩트 모드에서는 숨김)
            if !isCompact {
                HStack {
                    Spacer()
                    userProfileView
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
            } else {
                Spacer().frame(height: 16) // 상단 여백 유지
            }
            
            Spacer()
            
            // 하단 텍스트 정보
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(theme.name)
                        .font(.scoreDream(.bold, size: isCompact ? .subheadline : .body))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                    
                    // 화살표 아이콘
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: isCompact ? 16 : 20))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Text(theme.description)
                    .font(.scoreDream(.light, size: isCompact ? .footnote : .caption))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                
                HStack {
                    Spacer()
                    
                    Text(theme.createdAt.prefix(10))
                        .font(.scoreDream(.light, size: isCompact ? .caption2 : .footnote))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
        }
    }
    
    private var userProfileView: some View {
        HStack(spacing: 8) {
            // 프로필 이미지
            if let url = URL(string: theme.userId.profileImage), !theme.userId.profileImage.isEmpty {
                WebImage(url: url)
                    .placeholder {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 12))
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            } else {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 12))
                    )
            }
            
            Text(theme.userId.nickname)
                .font(.scoreDream(.medium, size: .caption))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
    }
    
    private var destinationView: some View {
        if theme.userId.id == userViewModel.user?.id {
            return AnyView(ThemeDetailView(theme: theme, isMy: true)
                .environmentObject(themesViewModel)
                .environmentObject(userViewModel))
        } else {
            return AnyView(ThemeDetailView(theme: theme, isMy: false)
                .environmentObject(themesViewModel)
                .environmentObject(userViewModel))
        }
    }
}
