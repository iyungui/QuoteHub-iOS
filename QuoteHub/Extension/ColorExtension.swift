//
//  ColorExtension.swift
//  QuoteHub
//
//  Created by 이융의 on 10/20/23.
//

import Foundation
import SwiftUI

extension Color {
    static let appAccent = Color("mainColor")
    
    // MARK: - Book Theme Colors with Dark Mode Support
    static let paperBeige = Color(
        light: Color(hex: "#E8D5B7"),
        dark: Color(hex: "#3C3328")
    )
    
    static let brownLeather = Color(
        light: Color(hex: "#8B7355"),
        dark: Color(hex: "#5A4A3A")
    )
    
    static let antiqueGold = Color(
        light: Color(hex: "#A0956B"),
        dark: Color(hex: "#8A7F5C")
    )
    
    // MARK: - Background Colors (더 연한 톤)
    static let lightPaper = Color(
        light: Color(hex: "#F5F0E8"),  // 매우 연한 페이퍼 색
        dark: Color(hex: "#2A241C")
    )
    
    static let softBeige = Color(
        light: Color(hex: "#F9F6F0"),  // 거의 흰색에 가까운 베이지
        dark: Color(hex: "#1F1B15")
    )
    
    static let inkBrown = Color(
        light: Color(hex: "#6B5B47"),  // 책의 잉크 색상
        dark: Color(hex: "#9B8B77")
    )
    
    // MARK: - UI Element Colors
    static let cardBackground = Color(
        light: Color.white,
        dark: Color(hex: "#2C2620")
    )
    
    static let secondaryCardBackground = Color(
        light: Color(hex: "#F8F5F0"),
        dark: Color(hex: "#3A342A")
    )
    
    static let bookGradientStart = Color(
        light: Color(hex: "#E8D5B7").opacity(0.15),
        dark: Color(hex: "#3C3328").opacity(0.25)
    )
    
    static let bookGradientEnd = Color(
        light: Color(hex: "#A0956B").opacity(0.1),
        dark: Color(hex: "#8A7F5C").opacity(0.2)
    )
    
    static let heroBackground = Color(
        light: Color.white.opacity(0.9),
        dark: Color(hex: "#2C2620").opacity(0.95)
    )
    
    static let shadowColor = Color(
        light: Color(hex: "#8B7355").opacity(0.15),
        dark: Color.black.opacity(0.4)
    )
    
    // MARK: - Text Colors
    static let primaryText = Color(
        light: Color(hex: "#4A3F2F"),
        dark: Color(hex: "#E8D5B7")
    )
    
    static let secondaryText = Color(
        light: Color(hex: "#6B5B47"),
        dark: Color(hex: "#A0956B")
    )
}

// MARK: - Color Scheme Helper
extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
    
    var uiColor: UIColor {
        return UIColor(self)
    }
}

// MARK: - Hex Color Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (1, 1, 1, 1) // Default to white if something goes wrong
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Environment Color Scheme Helper
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
