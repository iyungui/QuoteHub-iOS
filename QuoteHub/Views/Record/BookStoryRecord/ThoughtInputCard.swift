//
//  ThoughtInputCard.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

/// 북스토리 기록 - 느낀점 입력 카드
struct ThoughtInputCard: View {
    @Bindable var viewModel: StoryFormViewModel
    @FocusState private var isContentFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            CardHeader(title: "나의 생각", icon: "brain.head.profile", subtitle: "문장을 읽고 떠오른 생각을 기록해보세요")
            
            VStack(spacing: 8) {
                CustomTextEditor(
                    text: $viewModel.content,
                    placeholder: viewModel.contentPlaceholder,
                    minHeight: 150,
                    maxLength: viewModel.contentMaxLength,
                    isFocused: isContentFocused
                )
                .focused($isContentFocused)
                
                CountCharView(currentInputCount: viewModel.content.count, maxCount: viewModel.contentMaxLength)
            }
        }
    }
}

#Preview {
    ThoughtInputCard(viewModel: StoryFormViewModel())
}
