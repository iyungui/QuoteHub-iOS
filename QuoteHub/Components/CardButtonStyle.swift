//
//  CardButtonStyle.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

// MARK: - Custom Button Style
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
