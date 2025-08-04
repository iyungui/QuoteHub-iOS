//
//  View+Extensions.swift
//  QuoteHub
//
//  Created by 이융의 on 6/17/25.
//

import SwiftUI

// MARK: - BACKGROUND EXTENSION

extension View {
    func backgroundGradient() -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.softBeige.opacity(0.3),
                    Color.lightPaper.opacity(0.2),
                    Color.paperBeige.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    func backgroundCard(cornerRadius: CGFloat) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear,
                                    Color.antiqueGold.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        
    }
}

extension View {
    func adaptiveBackground() -> some View {
        self.background(Color.cardBackground)
    }
    
    func adaptiveShadow(radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 5) -> some View {
        self.shadow(color: Color.shadowColor, radius: radius, x: x, y: y)
    }
    
    func bookPaperBackground() -> some View {
        self.background(Color.lightPaper)
    }
}

// MARK: - HIDE KEYBOARD

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
