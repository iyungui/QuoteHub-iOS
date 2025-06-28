//
//  FontManager.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

// MARK: - FONT TYPE
enum FontType: String, CaseIterable {
    case scoreDream = "S-CoreDream"
    case gowunBatang = "GowunBatang"
    case ridiBatang = "RIDIBatang"
    
    var displayName: String {
        switch self {
        case .scoreDream:
            return "에스코어드림"
        case .gowunBatang:
            return "고운바탕"
        case .ridiBatang:
            return "리디바탕"
        }
    }
}

// MARK: - FONT WEIGHT
enum FontWeight: String, CaseIterable {
    case thin = "thin"
    case extraLight = "extraLight"
    case light = "light"
    case regular = "regular"
    case medium = "medium"
    case bold = "bold"
    case extraBold = "extraBold"
    case heavy = "heavy"
    case black = "black"
    
    var displayName: String {
        switch self {
        case .thin: return "Thin"
        case .extraLight: return "Extra Light"
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .bold: return "Bold"
        case .extraBold: return "Extra Bold"
        case .heavy: return "Heavy"
        case .black: return "Black"
        }
    }
}

// MARK: - FONT SIZE
enum FontSize: CGFloat, CaseIterable {
    case caption2 = 11
    case caption = 12
    case footnote = 13
    case subheadline = 15
    case callout = 16
    case body = 17
    case title3 = 20
    case title2 = 22
    case title1 = 28
    case largeTitle = 34
    
    // 커스텀 사이즈
    case small = 14
    case medium = 18
    case large = 24
    case xlarge = 30
    case xxlarge = 36
}

struct FontManager {
    // UserDefaults에 저장되는 현재 폰트 설정
    static var currentFontType: FontType {
        get {
            // 기본폰트는 scoreDream
            let saved = UserDefaults.standard.string(forKey: "selectedFontType") ?? FontType.ridiBatang.rawValue
            return FontType(rawValue: saved) ?? .ridiBatang
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedFontType")
        }
    }
    
    // 폰트 변경 (시스템 UI 업데이트 포함)
    static func changeFontType(to fontType: FontType) {
        currentFontType = fontType
        Task {
            updateSystemFonts()
        }
    }
    
    // 각 폰트별 Weight 매핑
    private static func mapWeight(_ weight: FontWeight, for fontType: FontType) -> String {
        switch fontType {
        case .scoreDream:
            switch weight {
            case .thin: return "S-CoreDream-1Thin"
            case .extraLight: return "S-CoreDream-2ExtraLight"
            case .light: return "S-CoreDream-3Light"
            case .regular: return "S-CoreDream-4Regular"
            case .medium: return "S-CoreDream-5Medium"
            case .bold: return "S-CoreDream-6Bold"
            case .extraBold: return "S-CoreDream-7ExtraBold"
            case .heavy: return "S-CoreDream-8Heavy"
            case .black: return "S-CoreDream-9Black"
            }
            
        case .gowunBatang:
            switch weight {
            case .thin, .extraLight, .light, .regular, .medium:
                return "GowunBatang-Regular"
            case .bold, .extraBold, .heavy, .black:
                return "GowunBatang-Bold"
            }
            
        case .ridiBatang:
            return "RIDIBatang"
        }
    }
    
    // 폰트 생성 메서드
    static func font(_ weight: FontWeight, size: FontSize) -> Font {
        let fontName = mapWeight(weight, for: currentFontType)
        return Font.custom(fontName, fixedSize: size.rawValue)
    }
    
    static func font(_ weight: FontWeight, size: CGFloat) -> Font {
        let fontName = mapWeight(weight, for: currentFontType)
        return Font.custom(fontName, fixedSize: size)
    }
    
    /// 특정 폰트 타입으로 폰트 생성(설정창에서 미리보기용)
    static func font(_ weight: FontWeight, size: FontSize, fontType: FontType) -> Font {
        let fontName = mapWeight(weight, for: fontType)
        return Font.custom(fontName, fixedSize: size.rawValue)
    }
    
    /// UIFont 생성 메서드 (시스템 UI용)
    private static func uiFont(_ weight: FontWeight, size: CGFloat, for fontType: FontType) -> UIFont {
        let fontName = mapWeight(weight, for: fontType)
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    // MARK: - 시스템 UI 폰트 업데이트 메서드
    static func updateSystemFonts() {
        // Navigation Bar 제목 폰트
        UINavigationBar.appearance().titleTextAttributes = [
            .font: uiFont(.medium, size: 17, for: currentFontType)
        ]
        
        // Navigation Bar 큰 제목 폰트
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .font: uiFont(.bold, size: 34, for: currentFontType)
        ]
        
        // 뒤로가기 버튼 폰트
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .font: uiFont(.regular, size: 17, for: currentFontType)
        ], for: .normal)
        
        // Tab Bar 폰트
        UITabBarItem.appearance().setTitleTextAttributes([
            .font: uiFont(.regular, size: 10, for: currentFontType)
        ], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([
            .font: uiFont(.medium, size: 10, for: currentFontType)
        ], for: .selected)
    }
    
    /// 앱 시작시 시스템폰트 초기화
    static func initialize() {
        Task { @MainActor in
            updateSystemFonts()
        }
    }
}

// MARK: - Extension Font

extension Font {
    static func appFont(_ weight: FontWeight, size: FontSize) -> Font {
        FontManager.font(weight, size: size)
    }
    
    static func appFont(_ weight: FontWeight, size: CGFloat) -> Font {
        FontManager.font(weight, size: size)
    }
    
    static func appFont(_ weight: FontWeight, size: FontSize, font: FontType) -> Font {
        FontManager.font(weight, size: size, fontType: font)
    }

    // 자주 사용하는 조합
    static var appTitle: Font {
        FontManager.font(.bold, size: .title1)
    }
    static var appBody: Font {
        FontManager.font(.regular, size: .body)
    }
    static var appHeadline: Font {
        FontManager.font(.bold, size: .body)
    }
    static var appCaption: Font {
        FontManager.font(.light, size: .caption)
    }
}


//
//// MARK: - S-CoreDream 폰트 매니저
//struct ScoreDreamFont {
//    
//    // MARK: - 폰트 Weight 정의
//    enum Weight: String, CaseIterable {
//        case thin = "S-CoreDream-1Thin"
//        case extraLight = "S-CoreDream-2ExtraLight"
//        case light = "S-CoreDream-3Light"
//        case regular = "S-CoreDream-4Regular"
//        case medium = "S-CoreDream-5Medium"
//        case bold = "S-CoreDream-6Bold"
//        case extraBold = "S-CoreDream-7ExtraBold"
//        case heavy = "S-CoreDream-8Heavy"
//        case black = "S-CoreDream-9Black"
//        
//        var displayName: String {
//            switch self {
//            case .thin: return "Thin"
//            case .extraLight: return "Extra Light"
//            case .light: return "Light"
//            case .regular: return "Regular"
//            case .medium: return "Medium"
//            case .bold: return "Bold"
//            case .extraBold: return "Extra Bold"
//            case .heavy: return "Heavy"
//            case .black: return "Black"
//            }
//        }
//    }
//    
//    // MARK: - 폰트 Size 정의
//    enum Size: CGFloat, CaseIterable {
//        case caption2 = 11
//        case caption = 12
//        case footnote = 13
//        case subheadline = 15
//        case callout = 16
//        case body = 17
////        case headline = 17
//        case title3 = 20
//        case title2 = 22
//        case title1 = 28
//        case largeTitle = 34
//        
//        // 커스텀 사이즈
//        case small = 14
//        case medium = 18
//        case large = 24
//        case xlarge = 30
//        case xxlarge = 36
//    }
//    
//    // MARK: - 폰트 생성 메서드
//    static func font(_ weight: Weight, size: Size) -> Font {
//        return Font.custom(weight.rawValue, size: size.rawValue)
//    }
//    
//    static func font(_ weight: Weight, size: CGFloat) -> Font {
//        return Font.custom(weight.rawValue, size: size)
//    }
//}
//
//// MARK: - Font Extension (편의 메서드)
//extension Font {
//    // 자주 사용하는 조합들
//    static var scoreDreamTitle: Font {
//        ScoreDreamFont.font(.bold, size: .title1)
//    }
//    
////    static var scoreDreamHeadline: Font {
////        ScoreDreamFont.font(.medium, size: .headline)
////    }
//    
//    static var scoreDreamBody: Font {
//        ScoreDreamFont.font(.regular, size: .body)
//    }
//    
//    static var scoreDreamCaption: Font {
//        ScoreDreamFont.font(.light, size: .caption)
//    }
//    
//    static var scoreDreamLargeTitle: Font {
//        ScoreDreamFont.font(.black, size: .largeTitle)
//    }
//    
//    static func appFont(_ weight: ScoreDreamFont.Weight, size: ScoreDreamFont.Size) -> Font {
//        ScoreDreamFont.font(weight, size: size)
//    }
//    
//    static func scoreDream(_ weight: ScoreDreamFont.Weight, size: CGFloat) -> Font {
//        ScoreDreamFont.font(weight, size: size)
//    }
//}
