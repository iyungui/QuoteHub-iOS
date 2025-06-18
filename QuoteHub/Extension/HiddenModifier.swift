//
//  HiddenModifier.swift
//  QuoteHub
//
//  Created by 이융의 on 6/11/25.
//

import SwiftUI

struct HiddenModifier: ViewModifier {
    let isHidden: Bool
    
    func body(content: Content) -> some View {
        if isHidden { content.hidden() } else { content }
    }
}

extension View {
    func hidden(_ isHidden: Bool) -> some View {
        modifier(HiddenModifier(isHidden: isHidden))
    }
}
