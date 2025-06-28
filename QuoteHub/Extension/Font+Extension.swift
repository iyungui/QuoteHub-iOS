//
//  Font+Extension.swift
//  QuoteHub
//
//  Created by 이융의 on 6/28/25.
//

import SwiftUI

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
