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
        HStack(spacing: 0) {
            // 홈 탭
            TabBarItem(
                icon: "house.fill",
                label: "홈",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
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
            
            // 내 서재 탭
            TabBarItem(
                icon: "books.vertical.fill",
                label: "내 서재",
                isSelected: selectedTab == 2
            ) {
                if userAuthManager.isUserAuthenticated {
                    selectedTab = 2
                } else {
                    showAlert()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
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
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.appAccent : Color.gray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundStyle(isSelected ? Color.appAccent : Color.gray)
            }
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
