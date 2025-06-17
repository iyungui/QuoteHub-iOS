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


// MARK: - Compact Reading Level Badge (for smaller spaces)

struct CompactReadingLevelBadge: View {
    let storyCount: Int
    let showProgress: Bool
    let showChevron: Bool

    init(storyCount: Int, showProgress: Bool = false, showChevron: Bool = false) {
        self.storyCount = storyCount
        self.showProgress = showProgress
        self.showChevron = showChevron
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
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.appAccent.opacity(0.8))
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

// MARK: - 스토리 카드에 작성자 레벨 표시

struct StoryCardWithUserLevel: View {
    let story: BookStory
    let authorStoryCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 스토리 내용
            Text(story.firstQuoteText)
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

// MARK: - 설정뷰에서 상세한 레벨 통계

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


// MARK: - 전체 예시 뷰

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
