//
//  ThemeToggleButton.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

/// 홈뷰에서 쓰는 테마 토글 버튼
struct ThemeToggleButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isDarkMode: Bool = false
    
    var body: some View {
        Button(action: toggleTheme) {
            ZStack {
                // 배경 원
                Circle()
                    .fill(Color.brownLeather.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                // 아이콘
                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.brownLeather)
                    .scaleEffect(isDarkMode ? 1.1 : 1.0)
                    .rotationEffect(.degrees(isDarkMode ? 0 : -15))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDarkMode)
        .onAppear {
            isDarkMode = colorScheme == .dark
        }
        .onChange(of: colorScheme) { _, newColorScheme in
            isDarkMode = newColorScheme == .dark
        }
    }
    
    private func toggleTheme() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isDarkMode.toggle()
        }
        
        // 테마 변경
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
}
