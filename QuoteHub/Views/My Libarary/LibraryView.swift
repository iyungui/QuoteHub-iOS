//
//  LibraryView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import SDWebImageSwiftUI

struct LibraryView: View {
    
    // MARK: - Properties
    
    // 친구 프로필인지 구분하는 프로퍼티
    let friendId: User?
    
    // 내 라이브러리인지 친구 라이브러리인지 구분
    var isMyLibaray: Bool { friendId == nil }   // friendId 가 nil 이면, 내 라이브러리
    
    init(friendId: User) {
        self.friendId = friendId
        self._friendStoriesViewModel = StateObject(wrappedValue: BookStoriesViewModel(mode: .friendStories(friendId.id)))
        self._friendFolderViewModel = StateObject(wrappedValue: FriendFolderViewModel(userId: friendId.id))
        self._followViewModel = StateObject(wrappedValue: FollowViewModel(userId: friendId.id))
    }
    
    @State private var selectedView: Int = 0    // 테마, 스토리 탭

    @Environment(\.colorScheme) var colorScheme // 다크모드 지원
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    // 뷰모델들
    /// 내 라이브러리용 뷰모델들 (환경 객체로 받음)
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel
    
    /// 공통?
    @StateObject var userViewModel = UserViewModel()
    
    /// 친구 라이브러리용 뷰모델들 (StateObject로 생성)
    // TODO: - 뷰모델 통합하기.. (북스토리뷰모델, 폴더뷰모델은 반드시 하나로 통합하기)
    @StateObject private var followViewModel: FollowViewModel
    @StateObject private var friendStoriesViewModel: BookStoriesViewModel
    @StateObject private var friendFolderViewModel: FriendFolderViewModel

    // 알림 관련
    @State private var showAlert: Bool = false
    @State private var alertType: AlertType = .loginRequired
    @State private var alertMessage = ""
    
    // 신고 관련 (친구 프로필에서만 사용)
    @State private var reportReason = ""
    @State private var showReportSheet = false
    @State private var showActionSheet = false

    // MARK: - BODY
    
    var body: some View {
        Group {
            /// 친구의 라이브러리이고 해당 친구가 차단된 사용자일 때
            if !isMyLibaray && followViewModel.isBlocked {
                blockedUserView
            } else {
                mainContent
            }
        }
        /// 알림창 (비로그인, 오류, 블럭?)
        .alert(isPresented: $showAlert) { alertView }
        
        /// 차단, 신고하기 버튼 시트
        .confirmationDialog(Text(""), isPresented: $showActionSheet) { actionSheetView }
        
        /// 유저 신고하기 창
        .sheet(isPresented: $showReportSheet) {
            if let friend = friendId {
                UserReportSheetView(
                    userId: friend.id,
                    reportReason: $reportReason
                ).environmentObject(followViewModel)
            }
        }
        
        /// 새로 고침
        .refreshable {
            await refreshContent()
        }
        
        .navigationBarTitleDisplayMode(.inline)
        
        /// 툴바
        .toolbar {
            ToolbarItem {
                if isMyLibaray { myLibraryNavBarItems }
                else { friendLibraryNavBarItems }
            }
        }
    }
    
    // MARK: - Private Views
    
    /// 차단된 사용자 뷰
    private var blockedUserView: some View {
        VStack {
            Spacer()
            ContentUnavailableView("차단된 사용자", systemImage: "person.crop.circle.badge.xmark.fill", description: Text("설정의 차단 목록을 확인해주세요."))
            Spacer()
        }
    }
    
    /// main 컨텐츠
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
//                if friendId != nil {
                    ProfileView(friendId: friendId)
                        .environmentObject(userViewModel)
                        .environmentObject(userAuthManager)

//                } else {
//                    ProfileView()
//                        .environmentObject(userViewModel)
//                        .environmentObject(userAuthManager)
//
//                }
                
                LibraryTabButtonView(selectedView: $selectedView)
                
                tabIndicator
                
                contentSection
                
                Spacer().frame(height: 50)
            }
            .padding(.top, 10)
        }
    }
    
    private var contentSection: some View {
        Group {
            
            if selectedView == 0 {
                // 테마 뷰
                if isMyLibaray {
                    if myFolderViewModel.folder.isEmpty {
                        ContentUnavailableView("아직 기록이 없어요", systemImage: "tray", description: Text("지금 바로 나만의 문장을 기록해보세요"))
                    } else {
                        MyLibraryThemeView()
                            .environmentObject(myFolderViewModel)
                            .environmentObject(userViewModel)
                            .environmentObject(myStoriesViewModel)
                    }
                } else {
                    if friendFolderViewModel.folder.isEmpty {
                        ContentUnavailableView("아직 기록이 없어요", systemImage: "tray")
                    } else {
                        FriendLibraryThemeView()
                            .environmentObject(friendStoriesViewModel)
                            .environmentObject(friendFolderViewModel)
                            .environmentObject(userAuthManager)
                    }
                }
            } else {
                // 스토리 뷰
                if isMyLibaray {
                    if myStoriesViewModel.bookStories.isEmpty {
                        ContentUnavailableView("아직 기록이 없어요", systemImage: "tray", description: Text("지금 바로 나만의 문장을 기록해보세요"))
                    } else {
                        MyLibraryStoryView()
                            .environmentObject(myStoriesViewModel)
                            .environmentObject(userViewModel)
                    }
                } else {
                    if friendStoriesViewModel.bookStories.isEmpty {
                        ContentUnavailableView("아직 기록이 없어요", systemImage: "tray")
                    } else {
                        FriendLibraryStoryView()
                            .environmentObject(friendStoriesViewModel)
                            .environmentObject(userAuthManager)
                    }
                }
            }
        }
    }
    
    private var myLibraryNavBarItems: some View {
        /// 내 라이브러리에는 '내 기록을 키워드로 찾을 수 있는 뷰. 와, 설정' 버튼
        HStack {
            NavigationLink(destination: MySearchKeywordView().environmentObject(myStoriesViewModel).environmentObject(userViewModel)) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 25, height: 25)
            }
            
            NavigationLink(destination: SettingView().environmentObject(userViewModel).environmentObject(userAuthManager)) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 25, height: 25)
            }
        }
    }
    
    private var friendLibraryNavBarItems: some View {
        /// 친구 라이브러리에는 액션시트(신고/차단) 활성화 버튼
        Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
        }
    }
    
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                ProfileView()
                    .environmentObject(userViewModel)
                    .environmentObject(userAuthManager)
                
                LibraryTabButtonView(selectedView: $selectedView)
                
                tabIndicator

                Group {
                    if selectedView == 0 {
                        if myFolderViewModel.folder.isEmpty {
                            ContentUnavailableView("아직 기록이 없어요", systemImage: "tray", description: Text("지금 바로 나만의 문장을 기록해보세요"))
                        } else {
                            LibraryThemaView()
                                .environmentObject(myFolderViewModel)
                                .environmentObject(userViewModel)
                                .environmentObject(myStoriesViewModel)
                        }
                    } else {
                        if myStoriesViewModel.bookStories.isEmpty {
                            ContentUnavailableView("아직 기록이 없어요", systemImage: "tray", description: Text("지금 바로 나만의 문장을 기록해보세요"))
                        } else {
                            LibraryStoryView()
                                .environmentObject(myStoriesViewModel)
                                .environmentObject(userViewModel)
                        }
                    }
                }
                
                Spacer().frame(height: 50)

            }
            .padding(.top, 10)
        }
        .onAppear(perform: onAppear)
        .refreshable {
            await refreshContent()
        }
        .toolbar {
            ToolbarItem {
                navBarItems
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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

    private func refreshContent() async {
        userViewModel.getProfile(userId: nil)
        userViewModel.loadStoryCount(userId: nil)
        myStoriesViewModel.refreshBookStories()
        myFolderViewModel.refreshFolders()
        followViewModel.setUserId(userViewModel.user?.id)
        followViewModel.loadFollowCounts()

    }
    private func onAppear() {
        userViewModel.getProfile(userId: nil)
        userViewModel.loadStoryCount(userId: nil)
        followViewModel.setUserId(userViewModel.user?.id)
        followViewModel.loadFollowCounts()
    }

    private var navBarItems: some View {
        HStack {
            NavigationLink(destination: MySearchKeywordView().environmentObject(myStoriesViewModel).environmentObject(userViewModel)) {
                Image(systemName: "magnifyingglass").foregroundColor(Color(.systemGray)).frame(width: 25, height: 25)
            }
            
            NavigationLink(
                destination: SettingView()
                    .environmentObject(userViewModel)
                    .environmentObject(userAuthManager)
            ) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 25, height: 25)
            }
        }
    }
}

struct LibraryThemaView: View {
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 20
    
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(myFolderViewModel.folder, id: \.id) { folder in
                NavigationLink(destination: ThemaView(folderId: folder.id)
                    .environmentObject(myFolderViewModel)
                    .environmentObject(userViewModel)
                    .environmentObject(myStoriesViewModel))
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
            if !myFolderViewModel.isLastPage {
                ProgressView().onAppear {
                    myFolderViewModel.loadMoreIfNeeded(currentItem: myFolderViewModel.folder.last)
                }
            }
        }
        .padding(.all, spacing)
    }
}

struct LibraryStoryView: View {
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var userViewModel: UserViewModel

    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 20
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(myStoriesViewModel.bookStories, id: \.id) { story in
                NavigationLink(destination: myBookStoryView(storyId: story.id).environmentObject(myStoriesViewModel).environmentObject(userViewModel)) {
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
            
            if !myStoriesViewModel.isLastPage {
                ProgressView().onAppear {
                    myStoriesViewModel.loadMoreIfNeeded(currentItem: myStoriesViewModel.bookStories.last)
                }
            }
        }
//        .onAppear {
//            myStoriesViewModel.loadBookStories()
//        }
        .padding(.all, 20)
    }
}
