//
//  ContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    @State private var isSplashView = true
    var body: some View {
        if isSplashView {
            LaunchScreenView()
                // TODO: 비동기 Task 추가
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            isSplashView = false
                        }
                    }
                }
        } else {
            
            Group {
                if userAuthManager.isUserAuthenticated || userAuthManager.isOnboardingComplete {
                    MainView().environmentObject(userAuthManager)
                } else {
                    OnboardingView().environmentObject(userAuthManager)
                }
            }
            .onAppear(perform: userAuthManager.validateToken)
        }
    }
}


