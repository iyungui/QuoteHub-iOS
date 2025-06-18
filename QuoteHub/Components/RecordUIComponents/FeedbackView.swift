//
//  FeedbackView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/10/25.
//

import SwiftUI

// MARK: - FEED BACK VIEW

struct FeedbackView: View {
    let message: String
    let isSuccess: Bool
    
    init(message: String, isSuccess: Bool = false) {
        self.message = message
        self.isSuccess = isSuccess
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(isSuccess ? .green : .orange)
                .font(.body)
            
            Text(message)
                .font(.scoreDream(.medium, size: .subheadline))
                .foregroundColor(isSuccess ? .green : .orange)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill((isSuccess ? Color.green : Color.orange).opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke((isSuccess ? Color.green : Color.orange).opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.asymmetric(insertion: .opacity, removal: .slide))
    }
}
