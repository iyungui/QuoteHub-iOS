//
//  tabIndicator.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI

public func tabIndicator(height: CGFloat, selectedView: Int) -> some View {
    let totalWidth = UIScreen.main.bounds.width
    let indicatorWidth = totalWidth * (2/3)
    let offsetWhenRight = totalWidth - indicatorWidth

    return ZStack(alignment: .leading) {
        Rectangle()
            .fill(Color.appAccent.opacity(0.8))
            .frame(width: indicatorWidth, height: height)
            .offset(x: selectedView == 0 ? 0 : offsetWhenRight)
            .animation(.easeInOut(duration: 0.2), value: selectedView)
    }
    .frame(width: totalWidth, height: 3, alignment: .leading)
}
