//
//  QuoteHubApp.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI
//import SwiftData

// QuoteHubApp 에서는 SwiftData ModelContainer 설정을 담당
@main
struct QuoteHubApp: App {
    @StateObject var authManager = UserAuthenticationManager()

    // SwiftData ModelContainer 설정
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            DraftStory.self
//        ])
//        
//        let modelConfiguration = ModelConfiguration(
//            schema: schema,
//            isStoredInMemoryOnly: false
//        )
//        
//        do {
//            return try ModelContainer(
//                for: schema,
//                configurations: [modelConfiguration]
//            )
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
//        .modelContainer(sharedModelContainer)
    }
}


