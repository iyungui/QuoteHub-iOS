//
//  QuoteHubApp.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI
import GoogleSignIn

@main
struct QuoteHubApp: App {
//    @StateObject var userAuthManager = UserAuthenticationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL(perform: { url in
                    GIDSignIn.sharedInstance.handle(url)
                })
                .onAppear {
                    // TODO: 사용자가 이미 있을 경우 로그인 스킵
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        
                    }
                }
//                .environmentObject(userAuthManager)
        }
    }
}


