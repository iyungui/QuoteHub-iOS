//
//  QuoteHubApp.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI
import SwiftData

@main
struct QuoteHubApp: App {
    @StateObject var userAuthManager = UserAuthenticationManager()

    // SwiftData ModelContainer 설정
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DraftStory.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userAuthManager)
//                .onAppear {
//                    task1()
//                }
        }
        .modelContainer(sharedModelContainer)
    }
    
//    func task1() {
//        for family in UIFont.familyNames {
//            print(family)
//            for names in UIFont.fontNames(forFamilyName: family) {
//                print("== \(names)")
//            }
//        }
//    }
}


