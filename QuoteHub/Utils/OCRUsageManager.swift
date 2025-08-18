//
//  OCRUsageManager.swift
//  QuoteHub
//
//  Created by iyungui on 8/18/25.
//

import Foundation

@MainActor
@Observable
final class OCRUsageManager {
    
    // MARK: - PROPERTIES
    
    private(set) var dailyUsageCount: Int = 0
    private(set) var lastResetDate: Date = Date()
    
    private let maxFreeUsage = 10   // 일일 최대 무료 사용량
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults Keys
    private let dailyUsageCountKey = "OCRDailyUsageCount"
    private let lastResetDateKey = "OCRLastResetDate"
    
    // MARK: - INITIALIZATION
    
    init() {
        loadFromPersistentStorage()
        resetDailyUsageIfNeeded()
    }
    
    // MARK: - Public Methods
    
    /// OCR 사용 가능 여부 확인
    func canUseOCR(isPremiumUser: Bool = false) -> Bool {
        resetDailyUsageIfNeeded()
        
        // 프리미엄 사용자는 무제한
        if isPremiumUser { return true }
        
        // 무료 사용자는 일일 제한 확인
        return dailyUsageCount < maxFreeUsage
    }
    
    /// OCR 사용 횟수 증가
    func incrementUsage() {
        resetDailyUsageIfNeeded()
        dailyUsageCount += 1
        saveToPersistentStorage()
    }
    
    /// 남은 무료 사용 횟수 반환
    func getRemainingFreeUsage() -> Int {
        resetDailyUsageIfNeeded()
        return max(0, maxFreeUsage - dailyUsageCount)
    }
    
    /// 최대 무료 사용 횟수 반환
    func getMaxFreeUsage() -> Int {
        return maxFreeUsage
    }
    
    /// 오늘 사용한 횟수 반환
    func getTodayUsageCount() -> Int {
        resetDailyUsageIfNeeded()
        return dailyUsageCount
    }

    // MARK: - PRIVATE METHODS
    
    /// 매일 자정 이후 첫 사용 시 리셋
    private func resetDailyUsageIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        
        // 마지막 리셋 날짜와 현재 날빠가 다른 날이면 리셋
        if !calendar.isDate(lastResetDate, inSameDayAs: now) {
            print("OCR - Reset DailyUsageCount: \(dailyUsageCount)", terminator: " -> ")
            dailyUsageCount = 0
            lastResetDate = now
            saveToPersistentStorage()
            print(dailyUsageCount)
        }
    }
    
    /// UserDefaults에 저장
    private func saveToPersistentStorage() {
        userDefaults.set(dailyUsageCount, forKey: dailyUsageCountKey)
        userDefaults.set(lastResetDate, forKey: lastResetDateKey)
    }
    
    /// UserDefaults에서 로드
    private func loadFromPersistentStorage() {
        dailyUsageCount = userDefaults.integer(forKey: dailyUsageCountKey)
        
        if let savedDate = userDefaults.object(forKey: lastResetDateKey) as? Date {
            lastResetDate = savedDate
        } else {
            // 첫 실행 시 현재 날짜로 설정
            lastResetDate = Date()
            saveToPersistentStorage()
        }
        
        print("OCR 사용정보 로드: 오늘 사용: \(dailyUsageCount)/\(maxFreeUsage), 마지막 리셋날짜: \(lastResetDate)")
    }
    
    
    #if DEBUG
    /// 디버그용: 사용 횟수 강제 리셋
    func debugResetUsage() {
        dailyUsageCount = 0
        lastResetDate = Date()
        saveToPersistentStorage()
        print("DEBUG: OCR 사용 횟수 강제 리셋")
    }
    
    /// 디버그용: 사용 횟수 강제 설정
    func debugSetUsage(_ count: Int) {
        dailyUsageCount = max(0, count)
        saveToPersistentStorage()
        print("DEBUG: OCR 사용 횟수 설정 → \(dailyUsageCount)")
    }
    #endif
}
