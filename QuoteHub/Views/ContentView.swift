//
//  ContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    var body: some View {
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
