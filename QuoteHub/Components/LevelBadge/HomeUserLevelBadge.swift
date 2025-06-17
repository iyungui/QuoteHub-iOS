//
//  HomeUserLevelBadge.swift
//  QuoteHub
//
//  Created by 이융의 on 6/17/25.
//

import SwiftUI

// MARK: - 홈뷰에서 간단한 레벨 배지 표시

struct HomeUserLevelBadge: View {
    let storyCount: Int
    
    var body: some View {
        CompactReadingLevelBadge(storyCount: storyCount, showProgress: false, showChevron: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.antiqueGold.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}
