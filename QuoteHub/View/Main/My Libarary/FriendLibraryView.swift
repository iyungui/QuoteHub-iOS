//
//  FriendLibraryView.swift
//  QuoteHub
//
//  Created by 이융의 on 10/16/23.
//

import SwiftUI
import SDWebImageSwiftUI

enum AlertType {
    case loginRequired
    case followError
    case blocked
}


struct FriendLibraryView: View {
    let friendId: User
    
    init(friendId: User) {
        self.friendId = friendId
        self._viewModel = StateObject(wrappedValue: BookStoriesViewModel(mode: .friendStories(friendId.id)))
        self._FolderViewModel = StateObject(wrappedValue: FriendFolderViewModel(userId: friendId.id))
        self._followViewModel = StateObject(wrappedValue: FollowViewModel(userId: friendId.id))
    }
    
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedView: Int = 0
    
    @StateObject private var userViewModel = UserViewModel()
    
    @StateObject private var viewModel:  BookStoriesViewModel
    @StateObject private var FolderViewModel: FriendFolderViewModel
    @StateObject var followViewModel: FollowViewModel
    @ObservedObject var userAuthManager = UserAuthenticationManager.shared

    @State private var showAlert: Bool = false
    @State private var alertType: AlertType = .loginRequired
    @State private var alertMessage = ""

    
    @StateObject var reportViewModel = ReportViewModel()
    @State private var reportReason = ""
    @State private var showReportSheet = false
    @State private var showActionSheet = false

    var body: some View {
        Group {
            if followViewModel.isBlocked {
                VStack {
                    Spacer()
                    Image(systemName: "person.crop.circle.badge.xmark.fill")
                        .font(.headline)
                        .padding()
                    Text("차단된 사용자입니다.\n설정의 차단 목록에서 확인해주세요.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        profileView
                        CustomTabView(selectedView: $selectedView)
                        tabIndicator
                        
                        Group {
                            if selectedView == 0 {
                                if FolderViewModel.folder.isEmpty {
                                    emptyStateText
                                } else {
                                    FriendLibraryThemaView()
                                        .environmentObject(viewModel)
                                        .environmentObject(FolderViewModel)
                                        .environmentObject(userViewModel)
                                }
                            } else {
                                if viewModel.bookStories.isEmpty {
                                    emptyStateText
                                } else {
                                    FriendLibraryStoryView()
                                        .environmentObject(viewModel)
                                }
                            }
                        }
                        .gesture(
                            DragGesture().onEnded { value in
                                if value.translation.width > 0 {
                                    self.selectedView = max(self.selectedView - 1, 0)
                                } else if value.translation.width < 0 {
                                    self.selectedView = min(self.selectedView + 1, 1)
                                }
                            }
                        )
                        Spacer().frame(height: 50)

                    }
                    .padding(.top, 10)
                }
                .alert(isPresented: $showAlert) {
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
                        return Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                    }
                }
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("선택"), buttons: [
                        .default(Text("차단하기"), action: {
                            if userAuthManager.isUserAuthenticated {
                                blockUser()
                            } else {
                                alertType = .loginRequired
                                showAlert = true
                            }
                        }),
                        .destructive(Text("신고하기"), action: {
                            if userAuthManager.isUserAuthenticated {
                                showReportSheet = true
                            } else {
                                alertType = .loginRequired
                                showAlert = true
                            }
                        }),
                        .cancel() // 취소 버튼
                    ])
                }
                
                .sheet(isPresented: $showReportSheet) {
                    UserReportSheetView(reportViewModel: reportViewModel, userId: friendId.id, reportReason: $reportReason).environmentObject(followViewModel)
                }
                .refreshable {
                    await refreshContent()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                    showActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                })
                .onAppear(perform: onAppear)
            }
        }
    }
    
    private func blockUser() {
        FollowService().updateFollowStatus(userId: friendId.id, status: "BLOCKED") { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.alertType = .blocked
                    followViewModel.updateFollowStatus(userId: friendId.id)
                    followViewModel.loadFollowCounts()
                }
            case .failure(let error):
                self.alertType = .blocked
                self.alertMessage = "오류: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
    
    private var emptyStateText: some View {
        VStack {
            Image(systemName: "tray")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            Text("아직 기록이 없어요")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var tabIndicator: some View {
        let totalWidth = UIScreen.main.bounds.width
        let indicatorWidth = totalWidth * (2/3)
        let offsetWhenRight = totalWidth - indicatorWidth

        return ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.secondary)
                .frame(width: indicatorWidth, height: 2)
                .offset(x: selectedView == 0 ? 0 : offsetWhenRight)
                .animation(.easeInOut(duration: 0.2), value: selectedView)
        }
        .frame(width: totalWidth, height: 3, alignment: .leading)
    }
    
    private var trailingNavigationItem: some View {
        NavigationLink(destination: FriendSearchKeywordView(friendId: friendId)) {
            Image(systemName: "number").foregroundColor(Color(.systemGray)).frame(width: 25, height: 25)
        }
    }
    
    private func refreshContent() async {
        userViewModel.getProfile(userId: friendId._id)
        userViewModel.loadStoryCount(userId: friendId._id)
        viewModel.refreshBookStories()
        FolderViewModel.refreshFolders()
        followViewModel.updateFollowStatus(userId: friendId.id)
        followViewModel.loadFollowCounts()
    }
    
    private func onAppear() {
        userViewModel.getProfile(userId: friendId._id)
        userViewModel.loadStoryCount(userId: friendId._id)
        followViewModel.updateFollowStatus(userId: friendId.id)
        viewModel.refreshBookStories()
        followViewModel.loadFollowCounts()
    }
    
    private var profileView: some View {
        VStack(alignment: .center, spacing: 10) {
            if let url = URL(string: userViewModel.user?.profileImage ?? ""), !(userViewModel.user?.profileImage ?? "").isEmpty {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .shadow(radius: 4)
                    .padding(.bottom)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.bottom)
            }

            
            Text(userViewModel.user?.nickname ?? "")
                .font(.title2)
                .fontWeight(.bold)
            
            Button(action: {
                if userAuthManager.isUserAuthenticated {
                    if followViewModel.isFollowing {
                        followViewModel.unfollowUser(userId: friendId.id)
                    } else {
                        followViewModel.followUser(userId: friendId.id)
                        // 에러 메시지 확인 후 알림 타입 설정
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let errorMessage = followViewModel.errorMessage, !errorMessage.isEmpty {
                                alertType = .followError
                                showAlert = true
                            }
                        }
                    }
                } else {
                    // 로그인이 필요한 경우 `loginRequired` 알림 타입을 설정합니다.
                    alertType = .loginRequired
                    showAlert = true
                }
            }) {
                Text(followViewModel.isFollowing ? "팔로잉" : "+ 팔로우")
                    .font(.callout)
                    .fontWeight(.bold)
                // 컬러 스킴과 팔로우 상태에 따라 텍스트 색상을 변경
                    .foregroundColor(followViewModel.isFollowing ? (colorScheme == .dark ? .white : .black) : (colorScheme == .dark ? .black : .white))
                    .frame(width: 100, height: 30)
                // 팔로우 상태에 따라 배경색과 아웃라인을 변경
                    .background(followViewModel.isFollowing ? Color.clear : (colorScheme == .dark ? .white : .black))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(followViewModel.isFollowing ? (colorScheme == .dark ? .white : .black) : Color.clear, lineWidth: 1)
                    )
                    .cornerRadius(15)
            }
            .buttonStyle(PlainButtonStyle())
            .environment(\.colorScheme, colorScheme)
            
            Text(userViewModel.user?.statusMessage ?? "")
                .font(.subheadline)
                .padding(.bottom, 10)
            
            HStack {
                // 팔로워 & 독서목표
                VStack {
                    NavigationLink(destination: FollowersListView(userId: friendId.id).environmentObject(followViewModel)) {
                        VStack {
                            Text("팔로워")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(followViewModel.followersCount)")
                                .font(.headline)
                        }
                    }

                    Spacer(minLength: 20) // 여백 추가

                    Text("독서목표")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(userViewModel.user?.monthlyReadingGoal ?? 0)")
                        .font(.headline)
                }

                Spacer().frame(width: 60)
                
                // 팔로잉 & 기록 수
                VStack {
                    NavigationLink(destination: FollowingListView(userId: friendId.id).environmentObject(followViewModel)) {
                        VStack {
                            Text("팔로잉")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(followViewModel.followingCount)")
                                .font(.headline)
                        }
                    }

                    Spacer(minLength: 20) // 여백 추가

                    Text("기록 수")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(userViewModel.storyCount ?? 0)")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 80)
        }
    }
}

struct FriendLibraryThemaView: View {
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 20
    
    @EnvironmentObject var FolderViewModel: FriendFolderViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var viewModel: BookStoriesViewModel

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(FolderViewModel.folder, id: \.id) { folder in
                NavigationLink(destination: FriendThemaView(folderId: folder.id, friendId: folder.userId)
                    .environmentObject(FolderViewModel)
                    .environmentObject(viewModel)
                    .environmentObject(userViewModel)
                )
                {
                    VStack(alignment: .leading) {
                        
                        if let url = URL(string: folder.folderImageURL), !folder.folderImageURL.isEmpty {
                            WebImage(url: url)
                                .resizable()
                                .scaledToFill()
                                .frame(width: (UIScreen.main.bounds.width / 2) - 35, height: (UIScreen.main.bounds.width / 2) - 35)
                                .cornerRadius(8)
                                .clipped()
                                .shadow(radius: 4)
                            
                        } else {
                            Color.gray
                                .frame(width: (UIScreen.main.bounds.width / 2) - 35, height: (UIScreen.main.bounds.width / 2) - 35)
                                .cornerRadius(8)
                                .clipped()
                                .shadow(radius: 4)
                        }
                        
                        Text(folder.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.top, 5)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom)
                }
            }
            if !FolderViewModel.isLastPage {
                ProgressView().onAppear {
                    FolderViewModel.loadMoreIfNeeded(currentItem: FolderViewModel.folder.last)
                }
            }
        }
        .padding(.all, spacing)
    }
}

struct FriendLibraryStoryView: View {
    @EnvironmentObject var viewModel: BookStoriesViewModel

    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 20
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(viewModel.bookStories, id: \.id) { story in
                NavigationLink(destination: friendBookStoryView(story: story).environmentObject(viewModel)) {
                    VStack(alignment: .leading, spacing: 10) {
                        WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.width / 2) - 60, height: (UIScreen.main.bounds.width / 2) - 20)
                            .cornerRadius(4)
                            .clipped()
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.25), lineWidth: 1))
                        
                        Text(story.quote ?? "")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(story.content ?? "")
                            .font(.subheadline)
                        
                        Text(story.keywords?.prefix(2).map { "#\($0)" }.joined(separator: " ") ?? "")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(2) // 텍스트 줄 수 제한
                    }
                    .frame(width: (UIScreen.main.bounds.width / 2) - 60, height: 250)
                    .padding(.all, 15)
                    .background(Color(.systemBackground))
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if !viewModel.isLastPage {
                ProgressView().onAppear {
                    viewModel.loadMoreIfNeeded(currentItem: viewModel.bookStories.last)
                }
            }
        }
        .padding(.all, 20)
    }
}
