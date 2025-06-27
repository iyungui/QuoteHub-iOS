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
        HStack(spacing: 40) {
            Spacer()
            ViewToggleButton(
                systemName: "square.grid.2x2",
                isSelected: selectedView == 0
            ) {
                selectedView = 0
            }
            Spacer()
            ViewToggleButton(
                systemName: "list.bullet.rectangle",
                isSelected: selectedView == 1
            ) {
                selectedView = 1
            }
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}


struct ViewToggleButton: View {
    let systemName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isSelected ? systemName + ".fill" : systemName)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
//            .background(
//                Circle()
//                    .overlay(
//                        Circle()                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                    )
//            )
        }
    }
}



