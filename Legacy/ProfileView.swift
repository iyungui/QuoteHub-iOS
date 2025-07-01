////
////  ProfileView.swift
////  QuoteHub
////
////  Created by 이융의 on 6/1/25.
////
//
//import SwiftUI
//
///// 라이브러리에서 보이는 프로필 뷰
//struct ProfileView: View {
//    @Environment(UserViewModel.self) private var userViewModel
//
//    @State private var showLevelBadgeSheet: Bool = false
//    
//    // 친구 프로필인지 구분하는 파라미터
//    let otherUser: User?
//    var storyCount: Int {
//        (otherUser != nil) ? userViewModel.currentOtherUserStoryCount ?? 0 : userViewModel.currentUserStoryCount ?? 0
//    }
//    
//    // 초기화 메서드
//    init(otherUser: User? = nil) {
//        self.otherUser = otherUser
//    }
//    
//    // 현재 표시할 사용자 ID
//    private var currentUser: User? {
//        return userViewModel.currentOtherUser ?? userViewModel.currentUser
//    }
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            HStack(alignment: .center, spacing: 20) {
//                ProfileImage(profileImageURL: currentUser?.profileImage ?? "", size: 60)
//                userInfo
//            }
//            .padding(25)
//            
//            ReadingProgressSection(storyCount: storyCount)
//        }
//        .sheet(isPresented: $showLevelBadgeSheet, content: {
//            AchievementBadgesView(storyCount: storyCount)
//        })
//    }
//    
//    // MARK: - UI Components
//    
//    private var userInfo: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            
//            HStack(alignment: .center) {
//                Text(currentUser?.nickname ?? "닉네임")
//                    .font(.scoreDream(.bold, size: .title3))
//                    .lineLimit(1)
//                
//                Button {
//                    showLevelBadgeSheet = true
//                } label: {
//                    HomeUserLevelBadge(storyCount: storyCount)
//                        .offset(y: -2)
//                }
//                Spacer()
//            }
//            Text(currentUser?.statusMessage ?? "상태메시지")
//                .font(.scoreDream(.regular, size: .subheadline))
//                .lineLimit(2)
//                .foregroundColor(.secondary)
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    ProfileView()
//        .environment(UserViewModel())
//}
