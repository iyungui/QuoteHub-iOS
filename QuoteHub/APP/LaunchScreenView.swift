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
            await loadPrivateUserData()
        }
        
        await loadPublicData()
        withAnimation { isSplashView = false }
    }
    
    private func loadPrivateUserData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await userViewModel.loadUserProfile(userId: nil)
            }
            group.addTask {
                await userViewModel.loadStoryCount(userId: nil)
            }
            group.addTask {
                await myBookStoriesViewModel.loadBookStories()
            }
            group.addTask {
                await myThemesViewModel.loadThemes()
            }
        }
    }
    
    private func loadPublicData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await publicBookStoriesViewModel.loadBookStories()
            }
            group.addTask {
                await publicThemesViewModel.loadThemes()
            }
        }
    }
}

#Preview {
    LaunchScreenView(isSplashView: .constant(false))
}
