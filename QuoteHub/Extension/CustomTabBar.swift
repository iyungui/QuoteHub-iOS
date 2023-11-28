//
//  CustomTabBar.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var shouldShowOverlay: Bool
    var showAlert: () -> Void  // 로그인 알림을 표시하기 위한 클로저 추가
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    var body: some View {
        HStack(spacing: 0) {
            // 홈 탭 아이템
            TabBarButton(icon: "house.fill", label: "홈", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            
            TabBarButton(icon: "plus.app.fill", label: "기록하기", isSelected: false) {
                shouldShowOverlay = true
            }
            

            
            // 내 서재 탭 아이템
            TabBarButton(icon: "books.vertical.fill", label: "내 서재", isSelected: selectedTab == 2) {
                // 여기서 userAuthManager의 상태를 확인하여 로그인 여부를 체크
                if userAuthManager.isUserAuthenticated {
                    selectedTab = 2
                } else {
                    // 로그인이 되어있지 않다면 selectedTab을 변경하지 않고
                    // showAlert 클로저를 호출하여 로그인이 필요하다는 알림 표시
                    showAlert()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50) // 탭 바의 크기 조정
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? Color.appAccent : .gray)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(isSelected ? Color.appAccent : .gray)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
                action()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
