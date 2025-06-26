//
//  ThemeEmptyStateView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct ThemeEmptyStateView: View {
    let isMy: Bool
    let viewType: ThemeViewType
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: iconName)
                .font(.system(size: 50))
                .foregroundColor(.secondaryText.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("아직 북스토리가 없어요")
                    .font(.scoreDream(.bold, size: .title3))
                    .foregroundColor(.primaryText)
                
                Text(emptyMessage)
                    .font(.scoreDream(.medium, size: .subheadline))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.antiqueGold.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    private var iconName: String {
        switch viewType {
        case .grid:
            return "folder.badge.questionmark"
        case .list:
            return "list.bullet.rectangle"
        }
    }
    
    private var emptyMessage: String {
        isMy ? "이 테마에 첫 번째 북스토리를 추가해보세요!" : "이 테마에는 아직 북스토리가 없습니다."
    }
}
