//
//  MyThemeNavigationItems.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct KeywordTags: View {
    let keywords: [String]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(keywords.prefix(2)), id: \.self) { keyword in
                Text("#\(keyword)")
                    .font(.appFont(.medium, size: .caption2))
                    .foregroundColor(.brownLeather)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.brownLeather.opacity(0.1))
                    )
            }
            
            if keywords.count > 2 {
                Text("+\(keywords.count - 2)")
                    .font(.appFont(.light, size: .caption2))
                    .foregroundColor(.secondaryText)
            }
        }
    }
}

// MARK: - LoadingGridCard.swift
import SwiftUI

struct LoadingGridCard: View {
    var body: some View {
        Rectangle()
            .fill(Color.paperBeige.opacity(0.3))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.brownLeather)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - LoadingListCard.swift
import SwiftUI

struct LoadingListCard: View {
    var body: some View {
        HStack(spacing: 16) {
            // 이미지 placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.paperBeige.opacity(0.3))
                .frame(width: 80, height: 80)
                .overlay(
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.brownLeather)
                )
            
            // 텍스트 placeholder
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.paperBeige.opacity(0.3))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.paperBeige.opacity(0.2))
                    .frame(height: 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.paperBeige.opacity(0.2))
                    .frame(height: 12)
                    .frame(maxWidth: 120, alignment: .leading)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
