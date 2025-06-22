//
//  ViewToggleButtons.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct ViewToggleButtons: View {
    @Binding var selectedView: Int
    
    var body: some View {
        HStack(spacing: 20) {
            Spacer()
            
            ViewToggleButton(
                systemName: "square.grid.2x2",
                title: "그리드",
                isSelected: selectedView == 0
            ) {
                selectedView = 0
            }
            
            ViewToggleButton(
                systemName: "list.bullet",
                title: "리스트",
                isSelected: selectedView == 1
            ) {
                selectedView = 1
            }
        }
    }
}


struct ViewToggleButton: View {
    let systemName: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemName)
                    .font(.subheadline.weight(.medium))
                Text(title)
                    .font(.scoreDream(.medium, size: .caption))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.appAccent : Color.clear)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
        }
    }
}
