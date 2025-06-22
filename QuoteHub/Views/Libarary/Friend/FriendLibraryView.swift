//
//  FriendLibraryView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct FriendLibraryView: View {
    // MARK: - Properties
    let friendUser: User
    
    // MARK: - ViewModels
    @Environment(ThemesViewModel.self) private var themesViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(BlockReportViewModel.self) private var blockReportViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @State private var friendBookStoriesViewModel: FriendBookStoriesViewModel
    
    // MARK: - State
    @State private var selectedTab: LibraryTab = .stories
    @State private var showAlert = false
    @State private var alertMessage: String?
    @State private var showReportSheet = false
    @State private var showActionSheet = false
    
    // MARK: - Initialization
    
    // 친구 북스토리 뷰모델은 친구 라이브러리 뷰 들어올 때마다 생성
    init(friendUser: User) {
        self.friendUser = friendUser
        self._friendBookStoriesViewModel = State(
            initialValue: FriendBookStoriesViewModel(friendId: friendUser.id)
        )
    }
    
    // MARK: - BODY
    var body: some View {
        LibraryBaseView(
            selectedTab: $selectedTab,
            profileSection: {
                LibraryProfileSection(
                    user: userViewModel.currentOtherUser ?? friendUser,
                    storyCount: userViewModel.currentOtherUserStoryCount ?? 0,
                    isMyProfile: false
                )
            },
            contentSection: {
                LibraryContentSection(
                    selectedTab: selectedTab,
                    storiesView: {
                        FriendLibraryStoriesView(
                            friendBookStoriesViewModel: friendBookStoriesViewModel
                        )
                    },
                    themesView: {
                        FriendLibraryThemesView(friendId: friendUser.id)
                    },
                    keywordsView: {
                        FriendLibraryKeywordsView()
                    }
                )
            },
            navigationBarItems: {
                FriendLibraryNavigationItems(
                    showActionSheet: $showActionSheet
                )
            }
        )
        .confirmationDialog("", isPresented: $showActionSheet) {
            friendActionSheet
        }
        .sheet(isPresented: $showReportSheet) {
            if let friend = userViewModel.currentOtherUser {
                ReportSheetView(
                    targetId: friend.id,
                    reportType: .user
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인") {}
        } message: {
            if let alertMessage = alertMessage {
                Text(alertMessage)
            } else {
                Text("이 기능을 사용하려면 로그인이 필요합니다.")
            }
        }
        .refreshable {
            await refreshFriendLibrary()
        }
        .task {
            await loadFriendLibrary()
        }
        .onDisappear {
            userViewModel.currentOtherUser = nil
            userViewModel.currentOtherUserStoryCount = nil
        }
        .progressOverlay(
            viewModels: userViewModel, friendBookStoriesViewModel, themesViewModel,
            opacity: false
        )
    }
    
    @ViewBuilder
    private var friendActionSheet: some View {
        Button("차단하기") {
            if userAuthManager.isUserAuthenticated {
                Task { await blockUser() }
            } else {
                showAlert = true
            }
        }
        
        Button("신고하기", role: .destructive) {
            if userAuthManager.isUserAuthenticated {
                showReportSheet = true
            } else {
                showAlert = true
            }
        }
        
        Button("취소", role: .cancel) { }
    }
    
    private func refreshFriendLibrary() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await userViewModel.loadUserProfile(userId: friendUser.id)
            }
            group.addTask {
                await userViewModel.loadStoryCount(userId: friendUser.id)
            }
            group.addTask {
                await friendBookStoriesViewModel.refreshBookStories()
            }
            group.addTask {
                await themesViewModel.refreshThemes(type: .friend(friendUser.id))
            }
        }
    }
    
    private func loadFriendLibrary() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await userViewModel.loadUserProfile(userId: friendUser.id)
            }
            group.addTask {
                await userViewModel.loadStoryCount(userId: friendUser.id)
            }
            group.addTask {
                await friendBookStoriesViewModel.loadBookStories()
            }
            group.addTask {
                await themesViewModel.loadThemes(type: .friend(friendUser.id))
            }
        }
    }
    
    private func blockUser() async {
        guard let friend = userViewModel.currentOtherUser else { return }
        
        let isSuccess = await blockReportViewModel.blockUser(friend.id)
        alertMessage = isSuccess ? blockReportViewModel.successMessage : blockReportViewModel.errorMessage
        showAlert = true
    }
}
