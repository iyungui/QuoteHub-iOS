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
    @StateObject private var followViewModel = FollowViewModel()

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
        VStack(alignment: .center, spacing: 20) {
            userImage
            userName
            if showFollowButton {
                followButton
            }
            userStatusMessage
            
            // 레벨 섹션
            ReadingLevelSection(storyCount: userViewModel.storyCount ?? 0)
            
            // 프로그레스 섹션
            ReadingProgressSection(storyCount: userViewModel.storyCount ?? 0)
            
            followStats
        }
        .onAppear {
            followViewModel.setUserId(currentUser?.id)
            followViewModel.loadFollowCounts()
            
            // 친구 프로필인 경우 팔로우 상태 업데이트
            if let friend = user {
                followViewModel.updateFollowStatus(userId: friend.id)
            }
        }
        .alert(isPresented: $showAlert) { alertView }
    }
    
    // MARK: - UI Components
    
    private var userImage: some View {
        Group {
            if let url = URL(string: currentUser?.profileImage ?? "") {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .shadow(radius: 4)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
        }
    }
    
    private var userName: some View {
        Text(currentUser?.nickname ?? "")
            .font(.scoreDream(.bold, size: .title2))
    }
    
    private var followButton: some View {
        Button(action: {
            guard let friend = user else { return }
            
            if userAuthManager.isUserAuthenticated {
                if followViewModel.isFollowing {
                    followViewModel.unfollowUser(userId: friend.id)
                } else {
                    followViewModel.followUser(userId: friend.id)
                }
            } else {
                alertType = .loginRequired
                showAlert = true
            }
        }) {
            Text(followViewModel.isFollowing ? "팔로잉" : "+ 팔로우")
                .font(.scoreDream(.bold, size: .callout))
                .foregroundColor(followViewModel.isFollowing ? (colorScheme == .dark ? .white : .black) : (colorScheme == .dark ? .black : .white))
                .frame(width: 100, height: 30)
                .background(followViewModel.isFollowing ? Color.clear : (colorScheme == .dark ? .white : .black))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(followViewModel.isFollowing ? (colorScheme == .dark ? .white : .black) : Color.clear, lineWidth: 1)
                )
                .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var userStatusMessage: some View {
        Text(currentUser?.statusMessage ?? "")
            .font(.scoreDream(.regular, size: .subheadline))
            .foregroundColor(.secondary)
    }
    
    private var followStats: some View {
        HStack(spacing: 40) {
            // 팔로워
            NavigationLink(destination: FollowersListView(userId: currentUser?.id).environmentObject(followViewModel).environmentObject(userAuthManager)) {
                VStack(spacing: 4) {
                    Text("\(followViewModel.followersCount)")
                        .font(.scoreDream(.bold, size: .title3))
                    Text("팔로워")
                        .font(.scoreDreamCaption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 팔로잉
            NavigationLink(
                destination: FollowingListView(userId: currentUser?.id)
                    .environmentObject(followViewModel)
                    .environmentObject(userAuthManager)
                    .environmentObject(userViewModel)
                    .environmentObject(storiesViewModel)
                    .environmentObject(themesViewModel)
            ) {
                VStack(spacing: 4) {
                    Text("\(followViewModel.followingCount)")
                        .font(.scoreDream(.bold, size: .title3))
                    Text("팔로잉")
                        .font(.scoreDreamCaption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 총 기록 수 또는 독서 목표 (친구 프로필인 경우)
            if showFollowButton {
                VStack(spacing: 4) {
                    Text("\(userViewModel.user?.monthlyReadingGoal ?? 0)")
                        .font(.scoreDream(.bold, size: .title3))
                    Text("독서목표")
                        .font(.scoreDreamCaption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 4) {
                    Text("\(userViewModel.storyCount ?? 0)")
                        .font(.scoreDream(.bold, size: .title3))
                    Text("기록 수")
                        .font(.scoreDreamCaption)
                        .foregroundColor(.secondary)
                }
            }
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
        .environmentObject(BookStoriesViewModel())
        .environmentObject(ThemesViewModel())
        .environmentObject(UserAuthenticationManager())
}
