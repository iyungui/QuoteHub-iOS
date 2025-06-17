//
//  GradientBackground.swift
//  QuoteHub
//
//  Created by 이융의 on 6/17/25.
//

import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.softBeige.opacity(0.3),
                Color.lightPaper.opacity(0.2),
                Color.paperBeige.opacity(0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
