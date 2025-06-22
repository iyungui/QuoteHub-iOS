//
//  LibraryTab.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import Foundation

enum LibraryTab: Int, CaseIterable {
    case stories = 0
    case themes = 1
    case keywords = 2
    
    var title: String {
        switch self {
        case .stories: return "스토리"
        case .themes: return "테마"
        case .keywords: return "키워드"
        }
    }
}
