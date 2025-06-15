//
//  ContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

// ContentView 에서는 앱 화면 분기처리

struct ContentView: View {
    @StateObject private var versionManager = AppVersionManager()

    @EnvironmentObject private var authManager: UserAuthenticationManager
    @State private var isSplashView = true  // 런치스크린 표시
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var storiesViewModel = BookStoriesViewModel()
    @StateObject private var themesViewModel = ThemesViewModel()
    
    var body: some View {
        if isSplashView {
            LaunchScreenView()
                // LaunchScreenView 나타날 때 토큰 검증 및 앱 버전 체크
                // TODO: - 여기서 .task 로 (유저, 북스토리, 테마) 데이터 모델을 미리 로드하고 전달하기.
                .task {
                    
                    await versionManager.checkVersionFromAppStore()
                    await authManager.validateAndRenewTokenNeeded()
                    
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    withAnimation {
                        isSplashView = false
                    }
                }
        } else {
            Group {
                // 앱을 시작할 때, 인증된 사용자라면 또는 게스트로그인 사용자라면 MainView로 가고,
                // 둘 다 해당되지 않는다면 OnboardingView 로 이동
                if authManager.isUserAuthenticated || authManager.isGuestMode {
                    MainView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(userViewModel)
            .environmentObject(storiesViewModel)
            .environmentObject(themesViewModel)
            
            // 앱 업데이트 필요 시, alert으로 유도
            .alert("업데이트 필요", isPresented: $versionManager.showUpdateAlert) {
                Button("확인") {
                    versionManager.goUpdate()
                    versionManager.closeApp()
                }
            } message: {
                Text("새 버전 \(versionManager.latestVersion)이 출시되었습니다.\n앱을 계속 사용하려면 업데이트해주세요.")
            }
        }
    }
}


