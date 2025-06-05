//
//  AppVersionManager.swift
//  QuoteHub
//
//  Created by 이융의 on 6/6/25.
//

import Foundation
import SwiftUI

struct AppStoreVersionResponse: Codable {
    let results: [AppStoreAppInfo]
}

struct AppStoreAppInfo: Codable {
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
    
    func checkVersionFromAppStore() {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appId)") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let response = try? JSONDecoder().decode(AppStoreVersionResponse.self, from: data),
                  let appInfo = response.results.first else { return }
            
            DispatchQueue.main.async {
                self?.compareVersions(latestVersion: appInfo.version)
            }
        }.resume()
    }
    
    private func compareVersions(latestVersion: String) {
        let comparison = currentVersion.compare(latestVersion, options: .numeric)
        
        if comparison == .orderedAscending {
            self.latestVersion = latestVersion
            showUpdateAlert = true
        }
    }
    
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
    
    func closeApp(){ //앱 종료 함수
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}
