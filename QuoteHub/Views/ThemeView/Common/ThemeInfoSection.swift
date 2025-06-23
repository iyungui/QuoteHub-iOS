//
//  ThemeInfoSection.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct ThemeInfoSection: View {
    let theme: Theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(theme.name)
                .font(.scoreDream(.bold, size: .title1))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
            
            if let description = theme.description, !description.isEmpty {
                Text(description)
                    .font(.scoreDream(.medium, size: .body))
                    .foregroundColor(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            
            HStack(spacing: 12) {
                // 공개/비공개 상태
                ThemeVisibilityTag(isPublic: theme.isPublic)
                
                // 생성일
                Text("생성일: \(theme.createdAt.prefix(10))")
                    .font(.scoreDream(.light, size: .caption))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}
