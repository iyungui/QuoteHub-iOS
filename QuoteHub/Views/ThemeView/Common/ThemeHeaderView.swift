//
//  ThemeHeaderView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ThemeHeaderView: View {
    let theme: Theme
    @Binding var selectedView: Int
    
    var body: some View {
        ZStack {
            // 배경 이미지
            if let imageURL = theme.themeImageURL {
                themeBackgroundImage(imageURL)
            }
            
            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 컨텐츠
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    // 테마 정보
                    ThemeInfoSection(theme: theme)
                    
                    // 뷰 전환 버튼들
                    ViewToggleButtons(selectedView: $selectedView)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 300)
    }
    
    private func themeBackgroundImage(_ imageURL: String) -> some View {
        WebImage(url: URL(string: imageURL))
            .placeholder {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.paperBeige.opacity(0.8),
                                Color.antiqueGold.opacity(0.6),
                                Color.brownLeather.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width, height: 300)
            .clipped()
    }
}
