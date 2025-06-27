//
//  KeywordInfo.swift
//  QuoteHub
//
//  Created by 이융의 on 6/23/25.
//

import Foundation

struct KeywordInfo: Identifiable, Hashable {
    let id = UUID()
    let keyword: String
    let count: Int
    
    init(keyword: String, count: Int) {
        self.keyword = keyword
        self.count = count
    }
}

enum KeywordSortOption: CaseIterable {
    case frequency  // 빈도순 (높은 순)
    case alphabetical  // 알파벳순
    
    var title: String {
        switch self {
        case .frequency:
            return "빈도순"
        case .alphabetical:
            return "가나다순"
        }
    }
    
    var systemImage: String {
        switch self {
        case .frequency:
            return "number.circle"
        case .alphabetical:
            return "textformat.abc"
        }
    }
}
