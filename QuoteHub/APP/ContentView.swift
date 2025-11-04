//
//  ContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

// ContentView 에서는 앱 화면 분기처리

struct ContentView: View {
    @State private var versionManager = AppVersionManager()
    @Environment(UserAuthenticationManager.self) private var authManager
    @State private var isSplashView = true

    var body: some View {
        if isSplashView {
            LaunchScreenView(isSplashView: $isSplashView)
        } else if authManager.showingNicknameSetup {
            NicknameSetupView(initialNickname: authManager.initialNickname)
        } else {
            mainContent
        }
    }
    
    private var mainContent: some View {
        Group {
            if authManager.isUserAuthenticated || authManager.isGuestMode {
                MainView()
            } else {
                OnboardingView()
            }
        }
        .task {
            await versionManager.checkVersionFromAppStore()
        }
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
