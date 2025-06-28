//
//  ReadingProgressSection.swift
//  QuoteHub
//
//  Created by 이융의 on 6/17/25.
//

import SwiftUI

// MARK: - Reading Progress Section

struct ReadingProgressSection: View {
    let storyCount: Int
    
    var body: some View {
        let currentLevel = ReadingLevelManager.calculateLevel(storyCount: storyCount)
        let nextLevelInfo = ReadingLevelManager.getNextLevelInfo(currentLevel: currentLevel.level)
        let progress = ReadingLevelManager.calculateProgress(storyCount: storyCount)
        let motivationMessage = ReadingLevelManager.getMotivationMessage(storyCount: storyCount)
        
        VStack(spacing: 12) {
            // 프로그레스 바
            VStack(spacing: 6) {
                HStack {
                    if nextLevelInfo.isMaxLevel {
                        Text("최고 레벨 달성!")
                            .font(.appFont(.medium, size: .subheadline))
                            .foregroundColor(.appAccent)
                        
                        
                    } else {
                        Text("다음 레벨까지")
                            .font(.appFont(.medium, size: .subheadline))

                    }
                    Spacer()

                    Text("\(storyCount)/\(nextLevelInfo.storiesNeeded)")
                        .font(.appFont(.medium, size: .subheadline))
                        .foregroundColor(.primary)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: nextLevelInfo.isMaxLevel ? .appAccent : .appAccent.opacity(0.8)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // 동기부여 메시지
            if nextLevelInfo.isMaxLevel {
                Text(motivationMessage)
                    .font(.appCaption)
                    .foregroundColor(.appAccent)
                    .multilineTextAlignment(.center)
            } else {
                let parts = motivationMessage.components(separatedBy: " 레벨까지")
                if parts.count >= 2 {
                    (
                        Text(parts[0])
                            .font(.appFont(.medium, size: .caption))
                            .foregroundColor(.blue) +
                        Text(" 레벨까지\(parts[1])")
                    )
                    .font(.appCaption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                } else {
                    Text(motivationMessage)
                        .font(.appCaption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, 25)
    }
}
