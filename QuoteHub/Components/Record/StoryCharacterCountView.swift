//
//  StoryCharacterCountView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/18/25.
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
