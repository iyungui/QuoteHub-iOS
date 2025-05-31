//
//  LaunchScreenView.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var logoOffset: CGFloat = UIScreen.main.bounds.width
    @State private var showTitle: Bool = false
    var body: some View {
        VStack(spacing: 25) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .offset(x: logoOffset)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.9)) {
                        logoOffset = 0
                        showTitle = true
                    }
                }
            
            if showTitle {
                Text("문장을 모아 지혜를 담다, 문장모아")
                    .font(.scoreDream(.bold, size: .medium))
                    .padding(.horizontal, 20)
                    .foregroundStyle(Color.appAccent)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
