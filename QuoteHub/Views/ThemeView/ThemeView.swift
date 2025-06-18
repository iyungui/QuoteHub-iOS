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

    @Environment(UserViewModel.self) private var userViewModel

    private var themeColors: [Color] {
        let colors: [Color] = [
            Color.warmBeige,
            Color.dustyBrown,
            Color.softTan,
            Color.mutedCoffee,
            Color.paleOchre,
            Color.subtleGray
        ]
        return [colors[index % colors.count]]
    }
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack {
                // 배경 이미지
                backgroundImage
                
                // 어둡게 처리
                darkOverlay
                
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
                    .fill(themeColors[0])
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: cardWidth, height: cardHeight)
    }
    
    private var darkOverlay: some View {
        // 이미지가 있을 때만 어둡게 처리
        Rectangle()
            .fill(Color.black.opacity(0.4))
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
                        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                    
                    Spacer()
                    
                    // 화살표 아이콘
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: isCompact ? 16 : 20))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                
                Text(theme.description)
                    .font(.scoreDream(.light, size: isCompact ? .footnote : .caption))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                HStack {
                    Spacer()
                    
                    Text(theme.createdAt.prefix(10))
                        .font(.scoreDream(.light, size: isCompact ? .caption2 : .footnote))
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.4), radius: 1, x: 0, y: 1)
                }
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
        }
    }
    
    private var userProfileView: some View {
        HStack(spacing: 8) {
            ProfileImage(profileImageURL: theme.userId.profileImage, size: 24)

            Text(theme.userId.nickname)
                .font(.scoreDream(.medium, size: .caption))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if theme.userId.id == userViewModel.currentUser?.id {
            ThemeDetailView(theme: theme, isMy: true)
        } else {
            ThemeDetailView(theme: theme, isMy: false)
        }
    }
}
