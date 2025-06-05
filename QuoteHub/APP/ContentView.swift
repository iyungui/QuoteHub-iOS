//
//  ContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

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
            // TODO: 비동기 Task 추가 - 앱 시작할 때 미리 데이터 로드
                .onAppear {
                    DispatchQueue.main.async {
                        authManager.validateToken()
                        versionManager.checkVersionFromAppStore()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
            .alert("업데이트 필요", isPresented: $versionManager.showUpdateAlert) {
                Button("업데이트") {
                    versionManager.goUpdate()
                    versionManager.closeApp()
                }
            } message: {
                Text("새 버전 \(versionManager.latestVersion)이 출시되었습니다.\n앱을 계속 사용하려면 업데이트해주세요.")
            }
        }
    }
}


