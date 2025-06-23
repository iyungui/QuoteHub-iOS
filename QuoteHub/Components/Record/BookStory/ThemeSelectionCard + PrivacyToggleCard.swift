//
//  ThemeSelectionCard + PrivacyToggleCard.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

/// 북스토리 기록 - 테마 선택 카드
struct ThemeSelectionCard: View {
    @EnvironmentObject var viewModel: StoryFormViewModel
    @State private var showThemeListView: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            StoryCreateGuideSection(message: "테마별로 기록을 분류해 보세요.\n이전보다 책의 내용을 정리하기 쉬워질 거예요.")
            
            Button(action: {
                showThemeListView = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "folder.fill")
                        .font(.title3)
                        .foregroundColor(.brownLeather)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("테마 선택하기")
                            .font(.scoreDream(.medium, size: .body))
                            .foregroundColor(.primaryText)
                        
                        Text(viewModel.themeIds.isEmpty ? "테마를 선택해주세요" : "\(viewModel.themeIds.count)개의 테마 선택됨")
                            .font(.scoreDream(.light, size: .caption))
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondaryText.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.paperBeige.opacity(0.3))
                )
            }
            .buttonStyle(CardButtonStyle())
        }
        .fullScreenCover(isPresented: $showThemeListView) {
            SetThemeView(selectedThemeIds: $viewModel.themeIds)
        }
    }
}

/// 북스토리 기록 - 공개 여부 설정 토글
struct PrivacyToggleCard: View {
    @EnvironmentObject var viewModel: StoryFormViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("공개 설정")
                    .font(.scoreDream(.medium, size: .body))
                    .foregroundColor(.primaryText)
                
                Text(viewModel.isPublic ? "다른 사용자들도 볼 수 있습니다" : "나만 볼 수 있습니다")
                    .font(.scoreDream(.light, size: .caption))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Toggle("", isOn: $viewModel.isPublic)
                .toggleStyle(PrivacyToggleStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.paperBeige.opacity(0.3))
        )
    }
}
