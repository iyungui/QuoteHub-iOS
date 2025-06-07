//
//  LibraryTabButtonView.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

/// 라이브러리에서 쓰는 테마/스토리 탭 전환 버튼
struct LibraryTabButtonView: View {
    @Binding var selectedView: Int

    var body: some View {
        HStack {
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
        .padding()
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
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundColor(isSelected ? .white : .secondary)
                .background(isSelected ? Color.appAccent : Color.clear)
                .frame(minWidth: 70, minHeight: 40)
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(10)
    }
}

#Preview {
    LibraryTabButtonView(selectedView: .constant(0))
}
