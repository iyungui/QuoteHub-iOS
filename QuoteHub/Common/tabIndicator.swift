//
//  tabIndicator.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI

public func tabIndicator(height: CGFloat, selectedView: Int, tabCount: Int) -> some View {
    let totalWidth = UIScreen.main.bounds.width
    let indicatorWidth: CGFloat
    
    // 탭 개수에 따른 인디케이터 너비 계산
    switch tabCount {
    case 2:
        indicatorWidth = totalWidth * (2/3)
    case 3:
        indicatorWidth = totalWidth * (1/3)
    default:
        indicatorWidth = totalWidth / CGFloat(tabCount) // 기본적으로 균등 분할
    }
    
    // 선택된 탭에 따른 오프셋 계산
    let offsetX: CGFloat
    switch tabCount {
    case 2:
        offsetX = selectedView == 0 ? 0 : (totalWidth - indicatorWidth)
    case 3:
        switch selectedView {
        case 0:
            offsetX = 0
        case 1:
            offsetX = totalWidth / 3
        case 2:
            offsetX = totalWidth * (2/3)
        default:
            offsetX = 0
        }
    default:
        // 기본적으로 균등 분할된 위치로 이동
        offsetX = (totalWidth / CGFloat(tabCount)) * CGFloat(selectedView)
    }

    return ZStack(alignment: .leading) {
        Rectangle()
            .fill(Color.appAccent.opacity(0.8))
            .frame(width: indicatorWidth, height: height)
            .offset(x: offsetX)
            .animation(.easeInOut(duration: 0.2), value: selectedView)
    }
    .frame(width: totalWidth, height: 3, alignment: .leading)
}
