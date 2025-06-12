//
//  AchievementBadgesView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/12/25.
//

import SwiftUI

struct AchievementBadgesView: View {
    let storyCount: Int
    @State private var animateBadges = false
    
    var body: some View {
        let level = ReadingLevelManager.calculateLevel(storyCount: storyCount)
        let totalBadges = getTotalBadgeCount(currentLevel: level.level)
        let gridHeight = calculateGridHeight(badgeCount: totalBadges)
        
        VStack(alignment: .leading, spacing: 24) {
            // 헤더 섹션
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                        .symbolEffect(.bounce, value: animateBadges)
                    
                    Text("달성한 배지")
                        .font(.scoreDream(.bold, size: .title3))
                }
                
                Text("독서 레벨에 따라 새로운 배지를 획득해보세요!")
                    .font(.scoreDream(.regular, size: .caption))
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // 배지 그리드
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 20) {
                ForEach(1...level.level, id: \.self) { achievedLevel in
                    if let achievedLevelInfo = getAchievedLevel(level: achievedLevel) {
                        AchievementBadge(
                            levelInfo: achievedLevelInfo,
                            isUnlocked: true,
                            animationDelay: Double(achievedLevel) * 0.1
                        )
                    }
                }
                
                // 다음 레벨 미리보기 (잠긴 상태)
                let nextLevelInfo = ReadingLevelManager.getNextLevelInfo(currentLevel: level.level)
                if !nextLevelInfo.isMaxLevel,
                   let nextLevel = getAchievedLevel(level: level.level + 1) {
                    AchievementBadge(
                        levelInfo: nextLevel,
                        isUnlocked: false,
                        animationDelay: Double(level.level + 1) * 0.1
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 20)
        }

        .presentationDetents([.height(gridHeight)])
        .presentationDragIndicator(.visible)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            animateBadges = true
        }
    }
    
    private func getTotalBadgeCount(currentLevel: Int) -> Int {
        let nextLevelInfo = ReadingLevelManager.getNextLevelInfo(currentLevel: currentLevel)
        return currentLevel + (nextLevelInfo.isMaxLevel ? 0 : 1)
    }
    
    private func calculateGridHeight(badgeCount: Int) -> CGFloat {
        let rows = ceil(Double(badgeCount) / 3.0)
        let badgeHeight: CGFloat = 100
        let spacing: CGFloat = 20
        let headerHeight: CGFloat = 80
        let bottomPadding: CGFloat = 40
        let topPadding: CGFloat = 12
        
        return headerHeight + topPadding + (CGFloat(rows) * badgeHeight) + (CGFloat(rows - 1) * spacing) + bottomPadding
    }
    
    private func getAchievedLevel(level: Int) -> ReadingLevel? {
        return ReadingLevelManager.calculateLevel(storyCount: getMinStoriesForLevel(level: level))
    }
    
    private func getMinStoriesForLevel(level: Int) -> Int {
        switch level {
        case 1: return 0
        case 2: return 3
        case 3: return 6
        case 4: return 10
        case 5: return 15
        case 6: return 20
        case 7: return 30
        case 8: return 60
        case 9: return 100
        case 10: return 150
        case 11: return 200
        case 12: return 300
        default: return 0
        }
    }
}

struct AchievementBadge: View {
    let levelInfo: ReadingLevel
    let isUnlocked: Bool
    let animationDelay: Double
    @State private var isVisible = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 8) {
            // 배지 아이콘
            Text(levelInfo.icon)
                .font(.title2)
                .opacity(isUnlocked ? 1.0 : 0.3)
                .symbolEffect(.bounce, options: .repeating, value: pulseAnimation)
                .scaleEffect(pulseAnimation && isUnlocked ? 1.05 : 1.0)
            
            // 배지 제목
            if isUnlocked {
                Text(levelInfo.title)
                    .font(.scoreDream(.medium, size: .caption))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .symbolEffect(.pulse, options: .repeating)
            }
        }
        .frame(width: 50, height: 60)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isUnlocked ?
                    Color(.systemBackground) :
                    Color(.systemBackground).opacity(0.5)
                )
                .shadow(
                    color: isUnlocked ? Color.appAccent.opacity(0.1) : Color.gray.opacity(0.1),
                    radius: isUnlocked ? 8 : 4,
                    x: 0,
                    y: isUnlocked ? 4 : 2
                )
        )
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
            .delay(animationDelay),
            value: isVisible
        )
        .onAppear {
            isVisible = true
            
            // 언락된 배지에만 펄스 애니메이션 적용
            if isUnlocked {
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay + 0.5) {
                    pulseAnimation = true
                }
            }
        }
        .onTapGesture {
            if isUnlocked {
                // 탭 시 작은 애니메이션
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    pulseAnimation.toggle()
                }
            }
        }
    }
}

#Preview {
    AchievementBadgesView(storyCount: 10)
}
