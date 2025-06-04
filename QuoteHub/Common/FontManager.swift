//
//  FontManager.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

// MARK: - S-CoreDream 폰트 매니저
struct ScoreDreamFont {
    
    // MARK: - 폰트 Weight 정의
    enum Weight: String, CaseIterable {
        case thin = "S-CoreDream-1Thin"
        case extraLight = "S-CoreDream-2ExtraLight"
        case light = "S-CoreDream-3Light"
        case regular = "S-CoreDream-4Regular"
        case medium = "S-CoreDream-5Medium"
        case bold = "S-CoreDream-6Bold"
        case extraBold = "S-CoreDream-7ExtraBold"
        case heavy = "S-CoreDream-8Heavy"
        case black = "S-CoreDream-9Black"
        
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
    
    // MARK: - 폰트 Size 정의
    enum Size: CGFloat, CaseIterable {
        case caption = 12
        case footnote = 13
        case subheadline = 15
        case callout = 16
        case body = 17
//        case headline = 17
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
    
    // MARK: - 폰트 생성 메서드
    static func font(_ weight: Weight, size: Size) -> Font {
        return Font.custom(weight.rawValue, size: size.rawValue)
    }
    
    static func font(_ weight: Weight, size: CGFloat) -> Font {
        return Font.custom(weight.rawValue, size: size)
    }
}

// MARK: - Font Extension (편의 메서드)
extension Font {
    // 자주 사용하는 조합들
    static var scoreDreamTitle: Font {
        ScoreDreamFont.font(.bold, size: .title1)
    }
    
//    static var scoreDreamHeadline: Font {
//        ScoreDreamFont.font(.medium, size: .headline)
//    }
    
    static var scoreDreamBody: Font {
        ScoreDreamFont.font(.regular, size: .body)
    }
    
    static var scoreDreamCaption: Font {
        ScoreDreamFont.font(.light, size: .caption)
    }
    
    static var scoreDreamLargeTitle: Font {
        ScoreDreamFont.font(.black, size: .largeTitle)
    }
    
    static func scoreDream(_ weight: ScoreDreamFont.Weight, size: ScoreDreamFont.Size) -> Font {
        ScoreDreamFont.font(weight, size: size)
    }
    
    static func scoreDream(_ weight: ScoreDreamFont.Weight, size: CGFloat) -> Font {
        ScoreDreamFont.font(weight, size: size)
    }
}
