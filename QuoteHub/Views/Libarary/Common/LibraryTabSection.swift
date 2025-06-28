//
//  LibraryTabSection.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct LibraryTabSection: View {
    @Binding var selectedTab: LibraryTab
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(LibraryTab.allCases, id: \.self) { tab in
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
                selectedView: selectedTab.rawValue,
                tabCount: LibraryTab.allCases.count
            )
        }
    }
}

struct LibraryTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(isSelected ? .appFont(.bold, size: .body) : .appBody)
                .foregroundColor(isSelected ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


