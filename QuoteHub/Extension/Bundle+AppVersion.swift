//
//  Bundle+AppVersion.swift
//  QuoteHub
//
//  Created by iyungui on 8/2/25.
//

import Foundation

extension Bundle {
    /// Fetches the current bundle version of the app.
    static var currentAppVersion: String? {
        #if os(macOS)
        let infoDictionaryKey = "CFBundleShortVersionString"
        #else
        let infoDictionaryKey = "CFBundleVersion"
        #endif
        
        return Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
    }
}
