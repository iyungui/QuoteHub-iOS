//
//  ProfileView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/1/25.
//

import SwiftUI
import SDWebImageSwiftUI

enum AlertType {
    case loginRequired
    case followError
    case blocked
}

/// 라이브러리에서 보이는 프로필 뷰
struct ProfileView: View {
    @EnvironmentObject private var followViewModel: FollowViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAlert: Bool = false
    @State private var alertType: AlertType = .loginRequired

    // 친구 프로필인지 구분하는 파라미터
    let user: User?
    var showFollowButton: Bool { user != nil }
    
    // 초기화 메서드
    init(user: User? = nil) {
        self.user = user
    }
    
    // 현재 표시할 사용자 ID (내 프로필이면 userViewModel.user?.id, 친구면 friendId?.id)
    private var currentUser: User? {
        return user ?? userViewModel.user
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                userImage
                userInfo
            }
            .padding(25)
            
            ReadingProgressSection(storyCount: userViewModel.storyCount ?? 0)
        }
        .alert(isPresented: $showAlert) { alertView }
    }
    
    // MARK: - UI Components
    
    private var userImage: some View {
        VStack {
            if let url = URL(string: currentUser?.profileImage ?? "") {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .shadow(radius: 4)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.gray)
                    .frame(width: 60, height: 60)
            }
        }
    }
    
    private var userInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                userName
                CompactReadingLevelBadge(storyCount: userViewModel.storyCount ?? 0)
                Spacer()
            }
            userStatusMessage
        }
    }
    
    private var userName: some View {
        Text(currentUser?.nickname ?? "닉네임")
            .font(.scoreDream(.bold, size: .title3))
            .lineLimit(1)
    }
    
    private var userStatusMessage: some View {
        Text(currentUser?.statusMessage ?? "상태메시지")
            .font(.scoreDream(.regular, size: .subheadline))
            .lineLimit(2)
            .foregroundColor(.secondary)
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
        .environmentObject(BookStoriesViewModel())
        .environmentObject(ThemesViewModel())
        .environmentObject(UserAuthenticationManager())
}
