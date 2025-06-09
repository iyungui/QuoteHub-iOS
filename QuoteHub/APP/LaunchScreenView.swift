//
//  LaunchScreenView.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI
import Lottie

struct LaunchScreenView: View {
    
    var body: some View {
        VStack(spacing: 25) {
            LottieView(animation: .named("quotehub_logo"))
                .playing(loopMode: .playOnce)
                .frame(height: 100)
        }
    }
}

#Preview {
    LaunchScreenView()
}
