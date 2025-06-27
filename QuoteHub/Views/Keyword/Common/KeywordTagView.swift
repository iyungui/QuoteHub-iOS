//
//  KeywordTagView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/23/25.
//

import SwiftUI

struct KeywordTagView: View {
    let keywordInfo: KeywordInfo
    let action: (() -> Void)?
    
    init(keywordInfo: KeywordInfo, action: (() -> Void)? = nil) {
        self.keywordInfo = keywordInfo
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 6) {
                Text("#\(keywordInfo.keyword)")
                    .font(.scoreDream(.medium, size: .caption))
                    .foregroundColor(.brownLeather)
                
                Text("(\(keywordInfo.count))")
                    .font(.scoreDream(.light, size: .caption2))
                    .foregroundColor(.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.brownLeather.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(Color.brownLeather.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
