//
//  CheckboxStyle.swift
//  QuoteHub
//
//  Created by 이융의 on 10/17/23.
//

import SwiftUI

struct CheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    configuration.isOn.toggle()
                }
            }) {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(configuration.isOn ? .appAccent : .secondaryText.opacity(0.6))
                    .font(.system(size: 20, weight: .medium, design: .default))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
