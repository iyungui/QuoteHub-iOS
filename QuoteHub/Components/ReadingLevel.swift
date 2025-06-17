//
//  ReadingLevel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/5/25.
//

import Foundation
import SwiftUI

// MARK: - Reading Level Model

struct ReadingLevel {
    let level: Int
    let title: String
    let icon: String
    let minStories: Int
    let maxStories: Int?
}

struct NextLevelInfo {
    let storiesNeeded: Int
    let nextLevelTitle: String
    let isMaxLevel: Bool
}

// MARK: - Reading Level Manager

class ReadingLevelManager {
    
    // MARK: - Level Configuration
    
    private static let levelConfig: [ReadingLevel] = [
        ReadingLevel(level: 1, title: "운석", icon: "☄️", minStories: 0, maxStories: 2),
        ReadingLevel(level: 2, title: "소행성", icon: "🪨", minStories: 3, maxStories: 5),
        ReadingLevel(level: 3, title: "달", icon: "🌕", minStories: 6, maxStories: 9),
        ReadingLevel(level: 4, title: "화성", icon: "🔴", minStories: 10, maxStories: 14),
        ReadingLevel(level: 5, title: "지구", icon: "🌍", minStories: 15, maxStories: 19),
        ReadingLevel(level: 6, title: "목성", icon: "🪐", minStories: 20, maxStories: 29),
        ReadingLevel(level: 7, title: "태양", icon: "☀️", minStories: 30, maxStories: 59),
        ReadingLevel(level: 8, title: "성운", icon: "🌫️", minStories: 60, maxStories: 99),
        ReadingLevel(level: 9, title: "은하", icon: "🌌", minStories: 100, maxStories: 149),
        ReadingLevel(level: 10, title: "은하단", icon: "🌀", minStories: 150, maxStories: 199),
        ReadingLevel(level: 11, title: "초은하단", icon: "🔭", minStories: 200, maxStories: 299),
        ReadingLevel(level: 12, title: "코스모스", icon: "💫", minStories: 300, maxStories: nil)
    ]
    
    // MARK: - Public Methods
    
    /// 스토리 개수로 현재 레벨 계산
    static func calculateLevel(storyCount: Int) -> ReadingLevel {
        for level in levelConfig {
            if let maxStories = level.maxStories {
                if storyCount >= level.minStories && storyCount <= maxStories {
                    return level
                }
            } else {
                // 최고 레벨 (maxStories가 nil)
                if storyCount >= level.minStories {
                    return level
                }
            }
        }
        
        // 기본값 (레벨 1)
        return levelConfig.first!
    }
    
    /// 다음 레벨 정보 가져오기
    static func getNextLevelInfo(currentLevel: Int) -> NextLevelInfo {
        // 현재 레벨의 다음 레벨 찾기
        if let nextLevel = levelConfig.first(where: { $0.level == currentLevel + 1 }) {
            return NextLevelInfo(
                storiesNeeded: nextLevel.minStories,
                nextLevelTitle: nextLevel.title,
                isMaxLevel: false
            )
        } else {
            // 최고 레벨 달성
            return NextLevelInfo(
                storiesNeeded: 0,
                nextLevelTitle: "",
                isMaxLevel: true
            )
        }
    }
    
    /// 프로그레스 계산
    static func calculateProgress(storyCount: Int) -> Double {
        let currentLevel = calculateLevel(storyCount: storyCount)
        let nextLevelInfo = getNextLevelInfo(currentLevel: currentLevel.level)
        
        if nextLevelInfo.isMaxLevel {
            return 1.0
        }
        
        let currentLevelMinStories = currentLevel.minStories
        let progress = Double(storyCount - currentLevelMinStories) / Double(nextLevelInfo.storiesNeeded - currentLevelMinStories)
        
        return min(max(progress, 0.0), 1.0) // 0.0 ~ 1.0 사이로 제한
    }
    
    /// 다음 레벨까지 남은 스토리 수
    static func storiesUntilNextLevel(storyCount: Int) -> Int {
        let currentLevel = calculateLevel(storyCount: storyCount)
        let nextLevelInfo = getNextLevelInfo(currentLevel: currentLevel.level)
        
        if nextLevelInfo.isMaxLevel {
            return 0
        }
        
        return max(nextLevelInfo.storiesNeeded - storyCount, 0)
    }
    
    /// 레벨별 동기부여 메시지
    static func getMotivationMessage(storyCount: Int) -> String {
        let currentLevel = calculateLevel(storyCount: storyCount)
        let nextLevelInfo = getNextLevelInfo(currentLevel: currentLevel.level)
        
        if nextLevelInfo.isMaxLevel {
            return "🌟 코스모스만큼 광활한 지식을 쌓으셨어요!"
        } else {
            let storiesLeft = storiesUntilNextLevel(storyCount: storyCount)
            return "\(nextLevelInfo.nextLevelTitle) 레벨까지 \(storiesLeft)권 남았어요!"
        }
    }
}

// MARK: - Reading Level Extensions

extension ReadingLevel: Equatable {
    static func == (lhs: ReadingLevel, rhs: ReadingLevel) -> Bool {
        return lhs.level == rhs.level
    }
}

extension ReadingLevel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(level)
    }
}
