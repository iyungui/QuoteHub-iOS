//
//  StoryCreateGuideSection.swift
//  QuoteHub
//
//  Created by 이융의 on 6/18/25.
//

import SwiftUI

// MARK: - STORY CREATE GUIDE SECTION

/// 북스토리 생성 가이드 메시지
struct StoryCreateGuideSection: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.scoreDream(.regular, size: .caption))
            .foregroundStyle(Color.blue)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.systemGray4), lineWidth: 0.5)
                    )
            )
    }
}
