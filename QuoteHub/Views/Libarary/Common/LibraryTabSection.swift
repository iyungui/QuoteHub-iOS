//
//  LibraryTabSection.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct LibraryTabSection: View {
    @Binding var selectedTab: LibraryTab
    let showKeywords: Bool // 키워드 탭 표시 여부
    
    private var availableTabs: [LibraryTab] {
        LibraryTab.availableTabs(showKeywords: showKeywords)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(availableTabs, id: \.self) { tab in
                    LibraryTabButton(
                        title: tab.title,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            TabIndicator(
                height: 3,
                selectedView: selectedTabIndex,
                tabCount: availableTabs.count
            )
        }
    }
    
    // 현재 선택된 탭의 인덱스를 사용 가능한 탭들 중에서 찾기
    private var selectedTabIndex: Int {
        return availableTabs.firstIndex(of: selectedTab) ?? 0
    }
}

struct LibraryTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(isSelected ? .scoreDream(.bold, size: .body) : .scoreDreamBody)
                .foregroundColor(isSelected ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


