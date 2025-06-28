//
//  LibraryProfileSection.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct LibraryProfileSection: View {
    let user: User?
    let storyCount: Int
    let isMyProfile: Bool
    
    @State private var showLevelBadgeSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center, spacing: 20) {
                ProfileImage(
                    profileImageURL: user?.profileImage ?? "",
                    size: 60
                )
                
                userInfo
            }
            .padding(25)
            
            ReadingProgressSection(storyCount: storyCount)
        }
        .sheet(isPresented: $showLevelBadgeSheet) {
            AchievementBadgesView(storyCount: storyCount)
        }
    }
    
    private var userInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text(user?.nickname ?? "닉네임")
                    .font(.appFont(.bold, size: .title3))
                    .lineLimit(1)
                
                Button {
                    showLevelBadgeSheet = true
                } label: {
                    HomeUserLevelBadge(storyCount: storyCount)
                        .offset(y: -2)
                }
                
                Spacer()
            }
            
            Text(user?.statusMessage ?? "상태메시지")
                .font(.appFont(.regular, size: .subheadline))
                .lineLimit(2)
                .foregroundColor(.secondary)
        }
    }
}
