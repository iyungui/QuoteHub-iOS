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
    @StateObject private var authManager = UserAuthenticationManager()
    @State private var userViewModel = UserViewModel()
    
    // 북스토리
    @State private var myBookStoriesViewModel = MyBookStoriesViewModel()
    @State private var publicBookStoriesViewModel = PublicBookStoriesViewModel()

    // 테마
    @State private var myThemesViewModel = MyThemesViewModel()
    @State private var publicThemesViewModel = PublicThemesViewModel()
    
    @State private var blockReportViewModel = BlockReportViewModel()
    @StateObject private var tabController = TabController()

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
                .environment(userViewModel)
                .environment(myThemesViewModel)
                .environment(publicThemesViewModel)
                .environmentObject(tabController)
                .environment(blockReportViewModel)
                .environment(myBookStoriesViewModel)
                .environment(publicBookStoriesViewModel)
        }
//        .modelContainer(sharedModelContainer)
    }
}


