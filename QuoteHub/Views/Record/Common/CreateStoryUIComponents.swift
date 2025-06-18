//
//  CreateStoryUIComponents.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

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
