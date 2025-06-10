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
            CardHeader(title: "테마 설정", icon: "folder.fill")
            
            Button(action: {
                showThemeListView = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
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
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.paperBeige.opacity(0.3))
                )
            }
            .buttonStyle(CardButtonStyle())
        }
        .padding(20)
        .background(CardBackground())
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        .fullScreenCover(isPresented: $showThemeListView) {
            SetThemeView(selectedThemeIds: $viewModel.themeIds)
        }
    }
}

/// 북스토리 기록 - 공개 여부 설정 토글
struct PrivacyToggleCard: View {
    @EnvironmentObject var viewModel: StoryFormViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            CardHeader(title: "공개 설정", icon: "eye.fill")
            
            HStack {
                Text(viewModel.isPublic ? "다른 사용자들도\n볼 수 있습니다" : "나만 볼 수 있습니다")
                    .font(.scoreDream(.light, size: viewModel.isPublic ? .caption2 : .caption))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Toggle("", isOn: $viewModel.isPublic)
                    .toggleStyle(SwitchToggleStyle())
                    .scaleEffect(0.9)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.paperBeige.opacity(0.3))
            )
        }
        .padding(20)
        .background(CardBackground())
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
