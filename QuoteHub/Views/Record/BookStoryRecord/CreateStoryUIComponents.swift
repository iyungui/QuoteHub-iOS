//
//  CreateStoryUIComponents.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

// MARK: - CUSTOM TEXT EDITOR

/// text editor with placeholder
struct CustomTextEditor: View {
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat
    let maxLength: Int
    let isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.paperBeige.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFocused ? Color.brownLeather.opacity(0.5) : Color.clear, lineWidth: 2)
                )
                .frame(minHeight: minHeight)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            if text.isEmpty {
                Text(placeholder)
                    .font(.scoreDream(.light, size: .body))
                    .foregroundStyle(Color.secondaryText.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .allowsHitTesting(false)
            }
            
            TextEditor(text: $text)
                .font(.scoreDream(.regular, size: .body))
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .onChange(of: text) { _, newValue in
                    if newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                }
        }
    }
}

struct CardHeader: View {
    let title: String
    let icon: String
    let subtitle: String?
    
    init(title: String, icon: String, subtitle: String? = nil) {
        self.title = title
        self.icon = icon
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.medium))
                .foregroundColor(.brownLeather)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.scoreDream(.bold, size: .body))
                    .foregroundColor(.primaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText.opacity(0.8))
                }
            }
            
            Spacer()
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.antiqueGold.opacity(0.8),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: 60)
        }
    }
}

struct CardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.antiqueGold.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
}

/// 입력한 글자수 보여주는 뷰
struct CountCharView: View {
    let currentInputCount: Int
    let maxCount: Int
    var textColor: Color {
        currentInputCount >= maxCount ? .orange : .secondaryText
    }
    
    var body: some View {
        HStack {
            Spacer()
            Text("\(currentInputCount)/\(maxCount)")
                .font(.scoreDream(.light, size: .caption2))
                .foregroundStyle(textColor)
        }
    }
}

/// 북스토리 생성 가이드 메시지
struct StoryCreateGuideSection: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.scoreDream(.light, size: .caption))
            .foregroundColor(.secondaryText)
    }
}
