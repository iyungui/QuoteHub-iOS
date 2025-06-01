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
    private var currentUserId: String? {
        return user?.id ?? userViewModel.user?.id
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            userImage
            userName
            if showFollowButton {
                followButton
            }
            userStatusMessage
            readingLevelSection
            readingProgressSection
            followStats
        }
        .onAppear {
            followViewModel.setUserId(currentUserId)
            followViewModel.loadFollowCounts()
            
            // 친구 프로필인 경우 팔로우 상태 업데이트
            if let friend = user {
                followViewModel.updateFollowStatus(userId: friend.id)
            }
        }
        .alert(isPresented: $showAlert) { alertView }
    }
    
    private var userImage: some View {
        Group {
            if let url = URL(string: userViewModel.user?.profileImage ?? ""), !(userViewModel.user?.profileImage ?? "").isEmpty {
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
        Text(userViewModel.user?.nickname ?? "")
            .font(.title2)
            .fontWeight(.bold)
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
                // TODO: 로그인 필요 알림 처리
                alertType = .loginRequired
                showAlert = true
            }
        }) {
            Text(followViewModel.isFollowing ? "팔로잉" : "+ 팔로우")
                .font(.callout)
                .fontWeight(.bold)
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
        Text(userViewModel.user?.statusMessage ?? "")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    private var readingLevelSection: some View {
        let level = calculateReadingLevel(storyCount: userViewModel.storyCount ?? 0)
        
        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(level.icon)
                    .font(.title2)
                Text(level.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Lv.\(level.level)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
        }
    }
    
    private var readingProgressSection: some View {
        let storyCount = userViewModel.storyCount ?? 0
        let currentLevel = calculateReadingLevel(storyCount: storyCount)
        let nextLevelInfo = getNextLevelInfo(currentLevel: currentLevel.level)
        let currentLevelMinStories = getLevelMinStories(level: currentLevel.level)
        let progress = nextLevelInfo.isMaxLevel ? 1.0 : Double(storyCount - currentLevelMinStories) / Double(nextLevelInfo.storiesNeeded - currentLevelMinStories)
        
        return VStack(spacing: 12) {
            // 프로그레스 바
            VStack(spacing: 6) {
                HStack {
                    Text("다음 레벨까지")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    if nextLevelInfo.isMaxLevel {
                        Text("최고 레벨 달성!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.appAccent)
                    } else {
                        Text("\(storyCount)/\(nextLevelInfo.storiesNeeded)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: nextLevelInfo.isMaxLevel ? .appAccent : .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // 동기부여 메시지
            if nextLevelInfo.isMaxLevel {
                Text("🌟 최고 레벨 달성! 코스모스만큼 광활한 지식을 쌓으셨어요!")
                    .font(.caption)
                    .foregroundColor(.appAccent)
                    .multilineTextAlignment(.center)
            } else {
                (Text(nextLevelInfo.nextLevelTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue) +
                 Text("레벨 까지 \(nextLevelInfo.storiesNeeded - storyCount)권 남았어요!"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var followStats: some View {
        HStack(spacing: 40) {
            // 팔로워
            NavigationLink(destination: FollowersListView(userId: currentUserId).environmentObject(followViewModel).environmentObject(userAuthManager)) {
                VStack(spacing: 4) {
                    Text("\(followViewModel.followersCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("팔로워")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 팔로잉
            NavigationLink(
                destination: FollowingListView(userId: currentUserId)
                    .environmentObject(followViewModel)
                    .environmentObject(userAuthManager)
                    .environmentObject(userViewModel)
                
                    .environmentObject(storiesViewModel)
                    .environmentObject(themesViewModel)

            ) {
                VStack(spacing: 4) {
                    Text("\(followViewModel.followingCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("팔로잉")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 총 기록 수 또는 독서 목표 (친구 프로필인 경우)
            if showFollowButton {
                VStack(spacing: 4) {
                    Text("\(userViewModel.user?.monthlyReadingGoal ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("독서목표")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 4) {
                    Text("\(userViewModel.storyCount ?? 0)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("기록 수")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // 레벨 계산 함수
    private func calculateReadingLevel(storyCount: Int) -> (level: Int, title: String, icon: String) {
        switch storyCount {
        case 0..<3:
            return (1, "운석", "☄️")
        case 3..<6:
            return (2, "소행성", "🪨")
        case 6..<10:
            return (3, "달", "🌕")
        case 10..<15:
            return (4, "화성", "🔴")
        case 15..<20:
            return (5, "지구", "🌍")
        case 20..<30:
            return (6, "목성", "🪐")
        case 30..<60:
            return (7, "태양", "☀️")
        case 60..<100:
            return (8, "성운", "🌫️")
        case 100..<150:
            return (9, "은하", "🌌")
        case 150..<200:
            return (10, "은하단", "🌀")
        case 200..<300:
            return (11, "초은하단", "🔭")
        default:
            return (12, "코스모스", "💫")
        }
    }
    
    // 다음 레벨 정보 가져오기
    private func getNextLevelInfo(currentLevel: Int) -> (storiesNeeded: Int, nextLevelTitle: String, isMaxLevel: Bool) {
        switch currentLevel {
        case 1:
            return (3, "소행성", false)
        case 2:
            return (6, "달", false)
        case 3:
            return (10, "화성", false)
        case 4:
            return (15, "지구", false)
        case 5:
            return (20, "목성", false)
        case 6:
            return (30, "태양", false)
        case 7:
            return (60, "성운", false)
        case 8:
            return (100, "은하", false)
        case 9:
            return (150, "은하단", false)
        case 10:
            return (200, "초은하단", false)
        case 11:
            return (300, "코스모스", false)
        default:
            return (0, "", true) // 최고 레벨
        }
    }
    
    // 현재 레벨의 최소 스토리 수 가져오기
    private func getLevelMinStories(level: Int) -> Int {
        switch level {
        case 1:
            return 0
        case 2:
            return 3
        case 3:
            return 6
        case 4:
            return 10
        case 5:
            return 15
        case 6:
            return 20
        case 7:
            return 30
        case 8:
            return 60
        case 9:
            return 100
        case 10:
            return 150
        case 11:
            return 200
        case 12:
            return 300
        default:
            return 0
        }
    }
    
    
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
