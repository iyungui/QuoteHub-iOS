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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Button(action: {
                    handleSignInWithApple()
                }) {
                    Image("appleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    handleSignInWithGoogle()
                }) {
                    Image("googleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    handleSignInWithKakao()
                }) {
                    Image("kakaoIcon")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 50, height: 50)
                        .background(Color(hex: "ffe812"))
                        .clipShape(.rect(cornerRadius: 5))
                }
            }
        }
        .padding()
    }
    
    private func handleSignInWithApple() {
        print("APLLE LOGIN")
    }
    
    private func handleSignInWithGoogle() {
        print("GOOGLE LOGIN")
        
//        guard let rootViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
//        
//        GIDSignIn.sharedInstance.signIn(
//            withPresenting: rootViewController) { signInResult, error in
//                guard let result = signInResult else {
//                    // Inspect error
//                    return
//                }
//                // If sign in succeeded, display the app's main content View.
//            }
    }
    
    private func handleSignInWithKakao() {
        print("KAKAO LOGIN")
    }
}
