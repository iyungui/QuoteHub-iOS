//
//  TabController.swift
//  QuoteHub
//
//  Created by 이융의 on 6/14/25.
//

import Foundation

// MARK: - for plus button sheet
enum ActiveSheet: Identifiable {
    case search, theme
    
    var id: String {
        switch self {
        case .search: return "search"
        case .theme: return "theme"
        }
    }
}

@Observable
class TabManager {
    var selectedTab: Int = 0
    var shouldNavigateToStoryDetail: Bool = false
    var activeSheet: ActiveSheet?

    var selectedStory: BookStory?
    
    /// 시트가 있으면 dismiss 후 tab and navigate
    /// 없으면 바로 tab and navigate
    func navigateToStory(_ story: BookStory) {
        selectedStory = story
        
        // Sheet가 활성화되어 있으면 먼저 내리기
        if activeSheet != nil {
            
            // Sheet가 내려간 후 네비게이션 수행
            activeSheet = nil
            
            // Sheet가 내려간 후 네비게이션 수행
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.changeTabAndNavigation()
            }
        } else {
            changeTabAndNavigation()
        }
    }
    
    private func changeTabAndNavigation() {
        selectedTab = 0 // library tab 으로 변경
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shouldNavigateToStoryDetail = true
        }
    }
    
    func resetNavigate() {
        shouldNavigateToStoryDetail = false
    }
}
