//
//  CustomTextEditor.swift
//  QuoteHub
//
//  Created by 이융의 on 6/18/25.
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
            // 텍스트 필드 배경
            Rectangle()
                .fill(Color.paperBeige.opacity(0.1))
                .overlay(
                    Rectangle()
                        .stroke(Color.brownLeather.opacity(0.1), lineWidth: 0.5)
                )
                .frame(minHeight: minHeight)
            
            // 플레이스 홀더
            if text.isEmpty {
                Text(placeholder)
                    .font(.scoreDream(.extraLight, size: .callout))
                    .foregroundStyle(Color.secondaryText.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.top, 20.5)
                    // placeholder 텍스트 터치 방지
                    .allowsHitTesting(false)
            }
            
            TextEditor(text: $text)
                .font(.scoreDream(.light, size: .callout))
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .scrollContentBackground(.hidden)
            // 최대 글자수 제한
                .onChange(of: text) { _, newValue in
                    if newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                }
        }
    }
}


#Preview {
    VStack {
        CustomTextEditor(
            text: .constant(""),
            placeholder: "간직하고 싶은 문장을 기록해보세요.",
            minHeight: 100,
            maxLength: 100,
            isFocused: true
        )
        .padding()
        Spacer()
    }
}
