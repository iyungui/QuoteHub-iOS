//
//  QuoteHubApp.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

@main
struct QuoteHubApp: App {
    @StateObject var userAuthManager = UserAuthenticationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userAuthManager)
        }
    }
}


