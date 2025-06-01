//
//  ContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: UserAuthenticationManager
    @State private var isSplashView = true  // 런치스크린 표시
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var storiesViewModel = BookStoriesViewModel()
    @StateObject private var themesViewModel = ThemesViewModel()
    
    var body: some View {
        if isSplashView {
            LaunchScreenView()
                // TODO: 비동기 Task 추가 - 앱 시작할 때 미리 데이터 로드
                .onAppear {
                    DispatchQueue.global().async {
                        authManager.validateToken()
                    }
                    
                    DispatchQueue.global().async {
                        if authManager.isUserAuthenticated {
                            loadData()
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            isSplashView = false
                        }
                    }
                }
        } else {
            Group {
                if authManager.isUserAuthenticated || authManager.isOnboardingComplete {
                    MainView()
                        .environmentObject(userViewModel)
                        .environmentObject(authManager)
                        .environmentObject(storiesViewModel)
                        .environmentObject(themesViewModel)
                } else {
                    OnboardingView().environmentObject(authManager)
                }
            }
        }
    }
    
    private func loadData() {
        userViewModel.getProfile(userId: nil)   // 내 프로필 정보 가져오기
        storiesViewModel.loadBookStories(type: .public) // 홈뷰에서 표시되는 북스토리 미리 가져오기
        themesViewModel.loadThemes(type: .public)   // 홈뷰에서 표시되는 테마 미리 가져오기
    }
}


