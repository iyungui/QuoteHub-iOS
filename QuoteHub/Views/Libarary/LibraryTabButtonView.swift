//
//  LibraryTabButtonView.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

struct LibraryTabButtonView: View {
    @Binding var selectedView: Int

    var body: some View {
        HStack(spacing: 0) {
            CustomTabButton(title: "스토리", isSelected: selectedView == 0) {
                selectedView = 0
            }

            CustomTabButton(title: "테마", isSelected: selectedView == 1) {
                selectedView = 1
            }
            
            CustomTabButton(title: "키워드", isSelected: selectedView == 2) {
                selectedView = 2
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct CustomTabButton: View {
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

#Preview {
    LibraryTabButtonView(selectedView: .constant(0))
}
