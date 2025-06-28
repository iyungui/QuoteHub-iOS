//
//  QuoteHubApp.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

@main
struct QuoteHubApp: App {
    @State private var authManager = UserAuthenticationManager()
    @State private var userViewModel = UserViewModel()
    
    // 북스토리
    @State private var myBookStoriesViewModel = MyBookStoriesViewModel()
    @State private var publicBookStoriesViewModel = PublicBookStoriesViewModel()
    
    // 테마
    @State private var myThemesViewModel = MyThemesViewModel()
    @State private var publicThemesViewModel = PublicThemesViewModel()
    
    @State private var blockReportViewModel = BlockReportViewModel()
    @StateObject private var tabController = TabController()

    // TODO: - SwiftData -> CoreData
    
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
    
    init() {
        // 앱 시작 시 시스템 폰트 초기화
        FontManager.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
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


