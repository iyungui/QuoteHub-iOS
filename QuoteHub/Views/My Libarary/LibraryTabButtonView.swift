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
        HStack {
            CustomTabButton(title: "테마", isSelected: selectedView == 0) {
                selectedView = 0
            }

            CustomTabButton(title: "스토리", isSelected: selectedView == 1) {
                selectedView = 1
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
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundColor(isSelected ? .white : .secondary)
                .background(isSelected ? Color.black : Color.clear)
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
