//
//  NavBarLogo.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI

public func NavBarLogo() -> some View {
    HStack(spacing: 8) {
        Image("logo")
            .resizable().scaledToFit().frame(height: 24)
        
        Text("문장모아")
            .font(.appBody)
            .foregroundStyle(Color.appAccent)
    }
}
