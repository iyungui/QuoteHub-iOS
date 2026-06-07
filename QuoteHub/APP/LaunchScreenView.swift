//
//  LaunchScreenView.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI
import Lottie

struct LaunchScreenView: View {
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(UserAuthenticationManager.self) private var authManager
    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel
    @Environment(PublicBookStoriesViewModel.self) private var publicBookStoriesViewModel
    @Environment(MyThemesViewModel.self) private var myThemesViewModel
    @Environment(PublicThemesViewModel.self) private var publicThemesViewModel

    @Binding var isSplashView: Bool
    
    var body: some View {
        VStack(spacing: 25) {
            LottieView(animation: .named("quotehub_logo"))
                .playing(loopMode: .playOnce)
                .frame(height: 100)
        }
        .task {
            await initializeApp()
        }
    }
    
    private func initializeApp() async {
        await authManager.validateAndRenewTokenNeeded()
        
        if authManager.isUserAuthenticated {
            async let privateData: Void = loadPrivateData()
            async let publicData: Void = loadPublicData()
            _ = await (privateData, publicData)
        }
        else {
            await loadPublicData()
        }
        
        withAnimation { isSplashView = false }
    }
    
    private func loadPrivateData() async {
        async let profile: Void = userViewModel.loadUserProfile(userId: nil)
        async let count:   Void = userViewModel.loadStoryCount(userId: nil)
        async let stories: Void = myBookStoriesViewModel.loadInitialIfNeeded()
        async let themes:  Void = myThemesViewModel.loadThemes()
        _ = await (profile, count, stories, themes)
    }

    private func loadPublicData() async {
        async let stories: Void = publicBookStoriesViewModel.loadInitialIfNeeded()
        async let themes:  Void = publicThemesViewModel.loadThemes()
        _ = await (stories, themes)
    }
}

#Preview {
    LaunchScreenView(isSplashView: .constant(false))
}
