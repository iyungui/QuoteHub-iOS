//
//  ThemeVisibilityTag.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct ThemeVisibilityTag: View {
    let isPublic: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isPublic ? "eye.fill" : "eye.slash.fill")
                .font(.caption)
            Text(isPublic ? "공개" : "비공개")
                .font(.appFont(.medium, size: .caption))
        }
        .foregroundColor(.white.opacity(0.8))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.3))
        )
    }
}

