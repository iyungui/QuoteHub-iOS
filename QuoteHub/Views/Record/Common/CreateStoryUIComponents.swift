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

// MARK: - CARD BACKGROUND

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

// MARK: - COUNT CHAR VIEW
/// 북스토리 입력 - 입력한 글자수 보여주는 뷰
struct StoryCharacterCountView: View {
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

// MARK: - STORY CREATE GUIDE SECTION

/// 북스토리 생성 가이드 메시지
struct StoryCreateGuideSection: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.scoreDream(.regular, size: .caption))
            .foregroundStyle(Color.blue)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.systemGray4), lineWidth: 0.5)
                    )
            )
    }
}

// MARK: - FEED BACK VIEW

struct FeedbackView: View {
    let message: String
    let isSuccess: Bool
    
    init(message: String, isSuccess: Bool = false) {
        self.message = message
        self.isSuccess = isSuccess
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(isSuccess ? .green : .orange)
                .font(.body)
            
            Text(message)
                .font(.scoreDream(.medium, size: .subheadline))
                .foregroundColor(isSuccess ? .green : .orange)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill((isSuccess ? Color.green : Color.orange).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke((isSuccess ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.asymmetric(insertion: .opacity, removal: .slide))
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
