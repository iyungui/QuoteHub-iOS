//
//  LaunchScreenView.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI
import Lottie

struct LaunchScreenView: View {
//    @State private var showTitle: Bool = false
    
    var body: some View {
        VStack(spacing: 25) {
            LottieView(animation: .named("quotehub_logo"))
                .playing(loopMode: .playOnce)
                .frame(height: 100)
            
//            if showTitle {
//                Text("문장을 모아 지혜를 담다, 문장모아")
//                .font(.custom("EF_jejudoldam", size: 17))
//                .font(.scoreDream(.bold, size: .caption))
//                    .padding(.horizontal, 20)
//                    .foregroundStyle(Color.appAccent)
//                    .transition(.opacity.combined(with: .move(edge: .bottom)))
//            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
