//
//  ProfileView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI

enum AlertType {
    case loginRequired
    case followError
    case blocked
}

/// 라이브러리에서 보이는 프로필 뷰
struct ProfileView: View {
    @EnvironmentObject private var followViewModel: FollowViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @State private var showAlert: Bool = false
    @State private var showLevelBadgeSheet: Bool = false
    @State private var alertType: AlertType = .loginRequired
    
    // 친구 프로필인지 구분하는 파라미터
    let otherUser: User?
    var storyCount: Int {
        (otherUser != nil) ? userViewModel.currentOtherUserStoryCount ?? 0 : userViewModel.currentUserStoryCount ?? 0
    }
    
    // 초기화 메서드
    init(otherUser: User? = nil) {
        self.otherUser = otherUser
    }
    
    // 현재 표시할 사용자 ID
    private var currentUser: User? {
        return userViewModel.currentOtherUser ?? userViewModel.currentUser
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center, spacing: 20) {
                ProfileImage(profileImageURL: currentUser?.profileImage ?? "", size: 60)
                userInfo
            }
            .padding(25)
            
            ReadingProgressSection(storyCount: storyCount)
        }
        .sheet(isPresented: $showLevelBadgeSheet, content: {
            AchievementBadgesView(storyCount: storyCount)
        })
        .alert(isPresented: $showAlert) { alertView }
    }
    
    // MARK: - UI Components
    
    private var userInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(alignment: .center) {
                Text(currentUser?.nickname ?? "닉네임")
                    .font(.scoreDream(.bold, size: .title3))
                    .lineLimit(1)
                
                Button {
                    showLevelBadgeSheet = true
                } label: {
                    HomeUserLevelBadge(storyCount: storyCount)
                        .offset(y: -2)
                }
                Spacer()
            }
            Text(currentUser?.statusMessage ?? "상태메시지")
                .font(.scoreDream(.regular, size: .subheadline))
                .lineLimit(2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Alert View
    
    private var alertView: Alert {
        switch alertType {
        case .loginRequired:
            return Alert(
                title: Text("로그인 필요"),
                message: Text("이 기능을 사용하려면 로그인이 필요합니다."),
                dismissButton: .default(Text("확인"))
            )
        case .followError:
            return Alert(
                title: Text("오류 발생"),
                message: Text(followViewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다."),
                dismissButton: .default(Text("확인"))
            )
        case .blocked:
            return Alert(title: Text("알림"), dismissButton: .cancel())
        }
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(UserViewModel())
        .environmentObject(FollowViewModel())
}
