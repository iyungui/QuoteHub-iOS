//
//  Data+Extension.swift
//  QuoteHub
//
//  Created by 이융의 on 6/26/25.
//

import Foundation

// MARK: - Data Extension
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
