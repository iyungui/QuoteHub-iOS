//
//  CustomTabbar.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

struct CustomTabbar: View {
    @Binding var selectedTab: Int
    @Binding var showActionButtons: Bool
    var showAlert: () -> Void
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 여백 (투명 영역)
            Spacer()
                .frame(height: 80) // 큰 여백으로 탭바 영역 확장
            
            // 실제 탭바 콘텐츠
            HStack(spacing: 0) {
                // 내 서재 탭
                TabBarItem(
                    icon: "books.vertical",
                    label: "내 서재",
                    isSelected: selectedTab == 0
                ) {
                    if userAuthManager.isUserAuthenticated {
                        selectedTab = 0
                    } else {
                        showAlert()
                    }
                }
                
                Spacer()
                
                // 가운데 플러스 버튼
                FloatingActionButton(
                    isActive: showActionButtons
                ) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showActionButtons.toggle()
                    }
                }
                
                Spacer()
                
                // 홈 탭
                TabBarItem(
                    icon: "network",
                    label: "홈",
                    isSelected: selectedTab == 2
                ) {
                    selectedTab = 2
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(
            // 그라데이션 배경으로 상단은 투명, 하단은 불투명
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.clear, location: 0.0),                    // 최상단: 완전 투명
                    .init(color: Color(.systemBackground).opacity(0.1), location: 0.1),  // 10%에서 시작
                    .init(color: Color(.systemBackground).opacity(0.4), location: 0.2),  // 20%에서 더 진하게
                    .init(color: Color(.systemBackground).opacity(0.7), location: 0.3),  // 30%에서 더 진하게
                    .init(color: Color(.systemBackground).opacity(0.9), location: 0.4),  // 40%에서 거의 불투명
                    .init(color: Color(.systemBackground), location: 0.5),       // 50%부터 완전 불투명
                    .init(color: Color(.systemBackground), location: 1.0)        // 하단: 완전 불투명
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - TabBarButton

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
//            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.appAccent : Color.gray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
//            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Floating Action Button

struct FloatingActionButton: View {
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appAccent, Color.appAccent.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: Color.appAccent.opacity(0.3),
                        radius: isActive ? 15 : 8,
                        x: 0,
                        y: isActive ? 8 : 4
                    )
                
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(isActive ? 45 : 0))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isActive ? 0.9 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isActive)
    }
}


#Preview {
    CustomTabbar(selectedTab: .constant(1), showActionButtons: .constant(true), showAlert: {})
}
