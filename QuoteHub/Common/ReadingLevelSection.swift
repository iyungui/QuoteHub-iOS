//
//  ReadingLevelComponents.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import SwiftUI

// MARK: - Reading Level Section

struct ReadingLevelSection: View {
    let storyCount: Int
    
    var body: some View {
        let level = ReadingLevelManager.calculateLevel(storyCount: storyCount)
        
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(level.icon)
                    .font(.title2)
                
                Text(level.title)
                    .font(.scoreDream(.medium, size: .body))
                
                Text("Lv.\(level.level)")
                    .font(.scoreDreamCaption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appAccent.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
        }
    }
}

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
                    Text("다음 레벨까지")
                        .font(.scoreDream(.medium, size: .subheadline))

                    Spacer()
                    
                    if nextLevelInfo.isMaxLevel {
                        Text("최고 레벨 달성!")
                            .font(.scoreDream(.medium, size: .subheadline))
                            .foregroundColor(.appAccent)
                    } else {
                        Text("\(storyCount)/\(nextLevelInfo.storiesNeeded)")
                            .font(.scoreDream(.medium, size: .subheadline))
                            .foregroundColor(.primary)
                    }
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: nextLevelInfo.isMaxLevel ? .appAccent : .appAccent.opacity(0.8)))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // 동기부여 메시지
            if nextLevelInfo.isMaxLevel {
                Text(motivationMessage)
                    .font(.scoreDreamCaption)
                    .foregroundColor(.appAccent)
                    .multilineTextAlignment(.center)
            } else {
                let parts = motivationMessage.components(separatedBy: " 레벨까지")
                if parts.count >= 2 {
                    (Text(parts[0])
                        .font(.scoreDream(.medium, size: .caption))
                        .foregroundColor(.blue) +
                     Text(" 레벨까지\(parts[1])"))
                        .font(.scoreDreamCaption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text(motivationMessage)
                        .font(.scoreDreamCaption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, 25)
    }
}

// MARK: - Compact Reading Level Badge (for smaller spaces)

struct CompactReadingLevelBadge: View {
    let storyCount: Int
    let showProgress: Bool
    
    init(storyCount: Int, showProgress: Bool = false) {
        self.storyCount = storyCount
        self.showProgress = showProgress
    }
    
    var body: some View {
        let level = ReadingLevelManager.calculateLevel(storyCount: storyCount)
        
        HStack(spacing: 6) {
            Text(level.icon)
                .font(.caption)
            
            Text(level.title)
                .font(.scoreDream(.medium, size: .caption2))
            
            Text("Lv.\(level.level)")
                .font(.scoreDream(.bold, size: .caption2))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color.appAccent.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(4)
            
            if showProgress {
                let progress = ReadingLevelManager.calculateProgress(storyCount: storyCount)
                let nextLevelInfo = ReadingLevelManager.getNextLevelInfo(currentLevel: level.level)
                
                if !nextLevelInfo.isMaxLevel {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .appAccent.opacity(0.8)))
                        .frame(width: 40)
                        .scaleEffect(x: 1, y: 0.8, anchor: .center)
                }
            }
        }
    }
}

// MARK: - Level Statistics View (for detailed stats)

struct LevelStatisticsView: View {
    let storyCount: Int
    
    var body: some View {
        let level = ReadingLevelManager.calculateLevel(storyCount: storyCount)
        let nextLevelInfo = ReadingLevelManager.getNextLevelInfo(currentLevel: level.level)
        let progress = ReadingLevelManager.calculateProgress(storyCount: storyCount)
        let storiesLeft = ReadingLevelManager.storiesUntilNextLevel(storyCount: storyCount)
        
        VStack(spacing: 16) {
            // 현재 레벨 정보
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("현재 레벨")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Text(level.icon)
                            .font(.title3)
                        
                        Text(level.title)
                            .font(.scoreDream(.bold, size: .subheadline))
                        
                        Text("Lv.\(level.level)")
                            .font(.scoreDream(.medium, size: .caption))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.appAccent.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                }
                
                Spacer()
                
                // 총 기록 수
                VStack(alignment: .trailing, spacing: 4) {
                    Text("총 기록")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondary)
                    
                    Text("\(storyCount)권")
                        .font(.scoreDream(.bold, size: .subheadline))
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            
            // 다음 레벨까지의 진행 상황
            if !nextLevelInfo.isMaxLevel {
                VStack(spacing: 8) {
                    HStack {
                        Text("다음 레벨: \(nextLevelInfo.nextLevelTitle)")
                            .font(.scoreDream(.medium, size: .subheadline))
                        
                        Spacer()
                        
                        Text("\(storiesLeft)권 남음")
                            .font(.scoreDream(.light, size: .caption))
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .appAccent))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            } else {
                // 최고 레벨 달성
                VStack(spacing: 8) {
                    Text("🌟 최고 레벨 달성! 🌟")
                        .font(.scoreDream(.bold, size: .subheadline))
                        .foregroundColor(.appAccent)
                    
                    Text("코스모스만큼 광활한 지식을 쌓으셨어요!")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appAccent.opacity(0.1))
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ReadingLevelSection(storyCount: 25)
        
        ReadingProgressSection(storyCount: 25)
        
        CompactReadingLevelBadge(storyCount: 25, showProgress: true)
        
        LevelStatisticsView(storyCount: 150)
    }
    .padding()
}


//
//  ReadingLevelUsageExamples.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import SwiftUI

// MARK: - Usage Examples

/// 다양한 컨텍스트에서 레벨 시스템을 사용하는 예시들

// MARK: - 1. 홈뷰에서 간단한 레벨 배지 표시

struct HomeUserLevelBadge: View {
    let storyCount: Int
    
    var body: some View {
        CompactReadingLevelBadge(storyCount: storyCount, showProgress: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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

// MARK: - 2. 스토리 카드에 작성자 레벨 표시

struct StoryCardWithUserLevel: View {
    let story: BookStory
    let authorStoryCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 스토리 내용
            Text(story.quote ?? "")
                .font(.scoreDream(.medium, size: .body))
                .lineLimit(3)
            
            // 작성자 정보 + 레벨
            HStack {
                Text(story.userId.nickname)
                    .font(.scoreDream(.medium, size: .subheadline))
                
                CompactReadingLevelBadge(storyCount: authorStoryCount)
                
                Spacer()
                
                Text(story.createdAt.prefix(10))
                    .font(.scoreDreamCaption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 3. 설정뷰에서 상세한 레벨 통계

struct UserStatsView: View {
    let storyCount: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("독서 통계")
                .font(.scoreDream(.bold, size: .title2))
            
            LevelStatisticsView(storyCount: storyCount)
            
            // 추가 통계들...
            monthlyProgress
        }
        .padding()
    }
    
    private var monthlyProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("이번 달 진행 상황")
                .font(.scoreDream(.bold, size: .subheadline))
            
            // 이번 달 목표 vs 실제
            HStack {
                VStack(alignment: .leading) {
                    Text("목표")
                        .font(.scoreDreamCaption)
                        .foregroundColor(.secondary)
                    Text("5권")
                        .font(.scoreDream(.bold, size: .body))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("달성")
                        .font(.scoreDreamCaption)
                        .foregroundColor(.secondary)
                    Text("3권")
                        .font(.scoreDream(.bold, size: .body))
                        .foregroundColor(.appAccent)
                }
            }
            
            ProgressView(value: 0.6)
                .progressViewStyle(LinearProgressViewStyle(tint: .appAccent))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 4. 성취 배지 시스템

struct AchievementBadgesView: View {
    let storyCount: Int
    
    var body: some View {
        let level = ReadingLevelManager.calculateLevel(storyCount: storyCount)
        
        VStack(alignment: .leading, spacing: 16) {
            Text("달성한 배지")
                .font(.scoreDream(.bold, size: .subheadline))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(1...level.level, id: \.self) { achievedLevel in
                    if let achievedLevelInfo = getAchievedLevel(level: achievedLevel) {
                        AchievementBadge(levelInfo: achievedLevelInfo, isUnlocked: true)
                    }
                }
                
                // 다음 레벨 미리보기 (잠긴 상태)
                let nextLevelInfo = ReadingLevelManager.getNextLevelInfo(currentLevel: level.level)
                if !nextLevelInfo.isMaxLevel,
                   let nextLevel = getAchievedLevel(level: level.level + 1) {
                    AchievementBadge(levelInfo: nextLevel, isUnlocked: false)
                }
            }
        }
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
    
    var body: some View {
        VStack(spacing: 6) {
            Text(levelInfo.icon)
                .font(.title2)
                .opacity(isUnlocked ? 1.0 : 0.3)
            
            Text(levelInfo.title)
                .font(.scoreDream(.medium, size: .caption2))
                .opacity(isUnlocked ? 1.0 : 0.5)
            
            if !isUnlocked {
                Text("잠김")
                    .font(.scoreDream(.light, size: .caption2))
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isUnlocked ? Color.appAccent.opacity(0.1) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isUnlocked ? Color.appAccent.opacity(0.3) : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isUnlocked ? 1.0 : 0.9)
        .animation(.easeInOut(duration: 0.2), value: isUnlocked)
    }
}

// MARK: - 5. 전체 예시 뷰

struct ReadingLevelExamplesView: View {
    @State private var selectedStoryCount: Int = 25
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 스토리 개수 조절
                    storyCountSlider
                    
                    Divider()
                    
                    // 다양한 컴포넌트 예시들
                    VStack(spacing: 20) {
                        sectionTitle("홈 배지")
                        HomeUserLevelBadge(storyCount: selectedStoryCount)
                        
                        sectionTitle("기본 레벨 섹션")
                        ReadingLevelSection(storyCount: selectedStoryCount)
                        
                        sectionTitle("프로그레스 섹션")
                        ReadingProgressSection(storyCount: selectedStoryCount)
                        
                        sectionTitle("컴팩트 배지")
                        HStack {
                            CompactReadingLevelBadge(storyCount: selectedStoryCount)
                            CompactReadingLevelBadge(storyCount: selectedStoryCount, showProgress: true)
                        }
                        
                        sectionTitle("상세 통계")
                        LevelStatisticsView(storyCount: selectedStoryCount)
                        
                        sectionTitle("성취 배지")
                        AchievementBadgesView(storyCount: selectedStoryCount)
                    }
                }
                .padding()
            }
            .navigationTitle("레벨 시스템 예시")
        }
    }
    
    private var storyCountSlider: some View {
        VStack(spacing: 12) {
            Text("스토리 개수: \(selectedStoryCount)")
                .font(.scoreDream(.bold, size: .subheadline))
            
            Slider(value: Binding(
                get: { Double(selectedStoryCount) },
                set: { selectedStoryCount = Int($0) }
            ), in: 0...350, step: 1)
            .accentColor(.appAccent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func sectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.scoreDream(.bold, size: .body))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    ReadingLevelExamplesView()
}
