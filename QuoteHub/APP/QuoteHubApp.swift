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
    @State private var authManager = UserAuthenticationManager()
    @State private var userViewModel = UserViewModel()
    @State private var myBookStoriesViewModel = MyBookStoriesViewModel()
    @State private var publicBookStoriesViewModel = PublicBookStoriesViewModel()
    @State private var myThemesViewModel = MyThemesViewModel()
    @State private var publicThemesViewModel = PublicThemesViewModel()
    @State private var blockReportViewModel = BlockReportViewModel()
    @State private var tabController = TabManager()

    private var sharedModelContainer: ModelContainer = {
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
    
    init() {
        FontManager.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(userViewModel)
                .environment(myThemesViewModel)
                .environment(publicThemesViewModel)
                .environment(blockReportViewModel)
                .environment(myBookStoriesViewModel)
                .environment(publicBookStoriesViewModel)
                .environment(tabController)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    InAppPurchaseManager.shared.refreshPurchaseStatus()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}


