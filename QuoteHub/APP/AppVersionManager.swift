//
//  AppVersionManager.swift
//  QuoteHub
//
//  Created by 이융의 on 6/6/25.
//

import Foundation
import SwiftUI

struct AppStoreVersionResponse: Codable, Sendable {
    let results: [AppStoreAppInfo]
}

struct AppStoreAppInfo: Codable, Sendable {
    let version: String
}

class AppVersionManager: ObservableObject {
    @Published var showUpdateAlert = false
    @Published var latestVersion = ""
    
    private let appId = "6469527373"
    private let currentVersion: String
    
    init() {
        self.currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    func checkVersionFromAppStore() async {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appId)") else { return }
        do {
            // url session에서 자동으로 백그라운드 스레드로 전환
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(AppStoreVersionResponse.self, from: data)
            guard let appInfo = decodedResponse.results.first else { return }
            
            // 메인스레드에서 ui 업데이트(alert)
            await MainActor.run {
                compareVersions(latestVersion: appInfo.version)
            }
        } catch {
            print("Failed to check app version: \(error.localizedDescription)")
        }
    }
    
    private func compareVersions(latestVersion: String) {
        let comparison = currentVersion.compare(latestVersion, options: .numeric)
        
        if comparison == .orderedAscending {
            self.latestVersion = latestVersion
            showUpdateAlert = true
        }
    }
    
    /// (앱 업데이트 위해) 앱스토어로 이동
    func goUpdate() {
        let url = "itms-apps://itunes.apple.com/app/\(appId)";
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    /// 앱 종료 함수
    func closeApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}
