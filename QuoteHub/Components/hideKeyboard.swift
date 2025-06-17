//
//  hideKeyboard.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

// MARK: - Extensions

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
