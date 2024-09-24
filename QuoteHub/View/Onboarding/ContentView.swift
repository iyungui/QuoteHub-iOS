//
//  ContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

//struct ContentView: View {
//    @EnvironmentObject var userAuthManager: UserAuthenticationManager
//
//    var body: some View {
//        Group {
//            if userAuthManager.isUserAuthenticated || userAuthManager.isOnboardingComplete {
//                MainView().environmentObject(userAuthManager)
//            } else {
//                OnboardingView().environmentObject(userAuthManager)
//            }
//        }
//        .onAppear(perform: userAuthManager.validateToken)
//    }
//}

struct ContentView: View {
    var body: some View {
        VStack {
            GoogleSignInButton(action: handleSignInButton)
        }
    }
    
    private func handleSignInButton() {
        guard let rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController) { signInResult, error in
                guard let result = signInResult else {
                    // Inspect error
                    return
                }
                // If sign in succeeded, display the app's main content View.
            }
    }
}
