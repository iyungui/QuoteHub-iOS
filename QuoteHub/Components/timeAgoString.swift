//
//  timeAgoString.swift
//  QuoteHub
//
//  Created by 이융의 on 6/19/25.
//

import Foundation

public func timeAgoString(from dateString: String) -> String {
    // ISO8601 형식의 날짜 문자열을 Date로 변환 (밀리초 포함)
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    guard let date = formatter.date(from: dateString) else {
        return "알 수 없음"
    }
    
    let now = Date()
    let daysDifference = Calendar.current.dateComponents([.day], from: date, to: now).day ?? 0
    
    // 7일이 지났으면 실제 날짜 표시
    if daysDifference >= 7 {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "M월 d일"
        
        // 올해가 아니면 년도도 표시
        let calendar = Calendar.current
        if !calendar.isDate(date, equalTo: now, toGranularity: .year) {
            dateFormatter.dateFormat = "yyyy년 M월 d일"
        }
        
        return dateFormatter.string(from: date)
    }
    
    // 7일 이내면 상대적 시간 표시
    let relativeFormatter = RelativeDateTimeFormatter()
    relativeFormatter.locale = Locale(identifier: "ko_KR")
    relativeFormatter.unitsStyle = .short  // "2분 전", "1시간 전" 형태
    
    return relativeFormatter.localizedString(for: date, relativeTo: now)
}
