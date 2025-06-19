//
//  TabIndicator.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI

public func TabIndicator(height: CGFloat, selectedView: Int, tabCount: Int) -> some View {
    let totalWidth = UIScreen.main.bounds.width - 40 // 좌우 패딩 20씩 제외
    let tabWidth = totalWidth / CGFloat(tabCount)
    let indicatorWidth: CGFloat = tabWidth * 0.6 // 각 탭 너비의 60%
    
    // 선택된 탭에 따른 오프셋 계산 (각 탭의 중앙에 위치)
    let offsetX: CGFloat = (tabWidth * CGFloat(selectedView)) + (tabWidth - indicatorWidth) / 2

    return ZStack(alignment: .leading) {
        // 구분선
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: totalWidth, height: 1)
        
        // 선택된 탭 인디케이터
        Rectangle()
            .fill(Color.appAccent)
            .frame(width: indicatorWidth, height: height)
            .offset(x: offsetX)
            .animation(.easeInOut(duration: 0.25), value: selectedView)
    }
    .frame(width: totalWidth, height: height, alignment: .leading)
    .padding(.horizontal, 20)
}
