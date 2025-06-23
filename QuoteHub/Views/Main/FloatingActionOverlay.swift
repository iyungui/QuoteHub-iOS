//
//  FloatingActionOverlay.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

struct FloatingActionOverlay: View {
    @Binding var showActionButtons: Bool
    @Binding var activeSheet: ActiveSheet?
    var showAlert: () -> Void
    @Environment(UserAuthenticationManager.self) private var userAuthManager

    var body: some View {
        ZStack {
            // 블러 배경
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissOverlay()
                }
                .transition(.opacity)
            
            // 액션 버튼들
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 16) {
                    // 테마 만들기 버튼
                    FloatingActionItem(
                        icon: "folder.badge.plus",
                        title: "테마 만들기",
                        subtitle: "나의 기록을 분류해보세요",
                        delay: 0.0
                    ) {
                        handleAction(.theme)
                    }
                    
                    // 문장 기록 버튼
                    FloatingActionItem(
                        icon: "square.and.pencil",
                        title: "문장 기록",
                        subtitle: "기억하고 싶은 문장을 남겨보세요",
                        delay: 0.1
                    ) {
                        handleAction(.search)
                    }
                }
                .padding(.bottom, 140) // 탭바 위 여유 공간
                .padding(.horizontal, 20)
            }
        }
        .animation(.easeOut(duration: 0.3), value: showActionButtons)
    }
    
    private func dismissOverlay() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showActionButtons = false
        }
    }
    
    private func handleAction(_ sheet: ActiveSheet) {
        if userAuthManager.isUserAuthenticated {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showActionButtons = false
                activeSheet = sheet
            }
        } else {
            // 로그인 필요 시 알람
            dismissOverlay()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showAlert()
            }
        }
    }
}

struct FloatingActionItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let delay: Double
    let action: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.title2)
                        .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.scoreDream(.medium, size: .body))
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.scoreDreamCaption)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.shadowColor, radius: 8, x: 0, y: 4)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 30)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}


#Preview {
    FloatingActionOverlay(showActionButtons: .constant(true), activeSheet: .constant(.search), showAlert: {}).environment(UserAuthenticationManager())
}
