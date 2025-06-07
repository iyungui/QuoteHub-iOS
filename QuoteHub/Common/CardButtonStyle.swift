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


struct MyActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .cornerRadius(8)
    }
}

struct BookButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .rotation3DEffect(
                .degrees(configuration.isPressed ? 0 : -3),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.8
            )
            .offset(y: configuration.isPressed ? -2 : 0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
