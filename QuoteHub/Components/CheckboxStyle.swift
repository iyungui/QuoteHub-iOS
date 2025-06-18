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

// MARK: - Custom Toggle Styles

struct PrivacyToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                configuration.isOn.toggle()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: configuration.isOn ? "eye.fill" : "eye.slash.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(configuration.isOn ? .blue : .secondaryText)
                    .frame(width: 20, height: 20)
                
                Text(configuration.isOn ? "공개" : "비공개")
                    .font(.scoreDream(.medium, size: .caption))
                    .foregroundColor(configuration.isOn ? .blue : .secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(configuration.isOn ? Color.appAccent.opacity(0.1) : Color.secondaryText.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(configuration.isOn ? Color.appAccent.opacity(0.3) : Color.secondaryText.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

