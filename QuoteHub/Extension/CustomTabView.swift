//
//  CustomTabView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/26/23.
//

import SwiftUI

struct CustomTabView: View {
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
