//
//  CardHeader.swift
//  QuoteHub
//
//  Created by 이융의 on 6/16/25.
//

import SwiftUI

// MARK: - CARD HEADER

struct CardHeader: View {
    let title: String
    let icon: String
    let subtitle: String?
    
    init(title: String, icon: String, subtitle: String? = nil) {
        self.title = title
        self.icon = icon
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(title)
                .font(.appFont(.bold, size: .body))
                .foregroundColor(.primaryText)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.appFont(.light, size: .caption))
                    .foregroundColor(.secondaryText.opacity(0.8))
            }
        }
    }
}
