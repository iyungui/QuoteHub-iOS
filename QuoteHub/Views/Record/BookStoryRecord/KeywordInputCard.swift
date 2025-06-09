//
//  KeywordInputCard.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

struct KeywordInputCard: View {
    @Bindable var viewModel: StoryFormViewModel
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            CardHeader(title: "키워드", icon: "tag.fill", subtitle: "최대 5개까지 입력 가능")
            
            VStack(spacing: 12) {
                if viewModel.keywords.count < 5 {
                    inputKeywordSection
                }
                
                if viewModel.isShowingDuplicateWarning {
                    showWarningSection
                }
                
                if viewModel.keywords.isEmpty {
                    StoryCreateGuideSection(message: "키워드를 입력하고 완료 버튼을 눌러주세요.")
                }
            }
        }
        .padding(20)
        .background(CardBackground())
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var inputKeywordSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "number")
                    .font(.body)
                    .foregroundStyle(Color.brownLeather.opacity(0.7))
                    .frame(width: 20)
                
                TextField("키워드 입력", text: $viewModel.currentInput)
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    .onChange(of: viewModel.currentInput) { _, newValue in
                        // keyword 최대 글자수를 넘어가면, 최대글자수로 재설정
                        if newValue.count > viewModel.keywordMaxLength {
                            viewModel.currentInput = String(newValue.prefix(viewModel.keywordMaxLength))
                        }
                    }
                    .onSubmit(viewModel.addKeyword)
                    .font(.scoreDream(.medium, size: .body))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.paperBeige.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isInputFocused ? Color.brownLeather.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isInputFocused)

            // 글자수 표시
            CountCharView(currentInputCount: viewModel.currentInput.count, maxCount: viewModel.keywordMaxLength)
        }
    }
    
    private var showWarningSection: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text("중복된 키워드입니다.")
                .font(.scoreDream(.medium, size: .caption))
                .foregroundColor(.orange)
            Spacer()
        }
        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
    }
}

// MARK: - Keyword Chip
struct KeywordChip: View {
    let keyword: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text("#\(keyword)")
                .font(.scoreDream(.medium, size: .caption))
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.brownLeather, .antiqueGold]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .shadow(color: .brownLeather.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}


#Preview {
    KeywordInputCard(viewModel: StoryFormViewModel())
}
