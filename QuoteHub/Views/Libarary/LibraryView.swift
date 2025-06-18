//
//  LibraryView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI

/// 내 라이브러리, 친구 라이브러리 모두 LibraryView 로 접근
/// 친구 라이브러리의 경우 user 파라미터를 추가로 받아서 구분
struct LibraryView: View {
    
    // MARK: - Properties
    
    /// 친구 프로필인지 구분하는 프로퍼티
    let otherUser: User?
    
    /// 내 라이브러리인지 친구 라이브러리인지 구분.
    /// otherUser 가 nil 이면, 내 라이브러리
    var isMyLibrary: Bool {
        return otherUser == nil
    }

    var loadType: LoadType {
        if !isMyLibrary {
            guard let friendId = otherUser?.id else {
                return LoadType.my
            }
            return LoadType.friend(friendId)  // 여기서 해당 사용자id로 북스토리와 테마 불러오도록 모드 설정
        } else {
            return LoadType.my
        }
    }
    
    // 초기화
    init(otherUser: User? = nil) {
        self.otherUser = otherUser
        self._followViewModel = StateObject(wrappedValue: FollowViewModel(userId: otherUser?.id))
    }
    
    // viewmodel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var tabController: TabController

    // 신고, 차단 기능을 위한
    @StateObject private var followViewModel: FollowViewModel

    @State private var selectedView: Int = 0    // 테마, 스토리 탭

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
        ZStack {
            GradientBackground()
            
            // 친구의 라이브러리이고 해당 친구가 차단된 사용자일 때
            if !isMyLibrary && followViewModel.isBlocked {
                ContentUnavailableView("차단된 사용자", systemImage: "person.crop.circle.badge.xmark.fill", description: Text("설정의 차단 목록을 확인해주세요."))
            } else {
                mainContent
            }
        }
        // 북스토리 생성, 업데이트 후 tabController에서 네비게이션 트리거
        .navigationDestination(isPresented: $tabController.shouldNavigateToStoryDetail) {
            if let story = tabController.selectedStory {
                BookStoryDetailView(story: story, isMyStory: true)
            }
        }
        // 툴바
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                navBarItems
            }
        }
        
        // 알림창 (비로그인, 오류, 블럭?)
        .alert(isPresented: $showAlert) { alertView }
        
        // 차단, 신고하기 버튼 시트
        .confirmationDialog(Text(""), isPresented: $showActionSheet) { actionSheetView }
        
        // 유저 신고하기 창
        .sheet(isPresented: $showReportSheet) {
            if let friend = userViewModel.currentOtherUser {
                UserReportSheetView(
                    userId: friend.id,
                    reportReason: $reportReason
                ).environmentObject(followViewModel)
            }
        }
        
        // 새로 고침
        .refreshable {
            if isMyLibrary {
                await userViewModel.loadUserProfile(userId: nil)
                await userViewModel.loadStoryCount(userId: nil)
                
            } else if let otherUser = userViewModel.currentOtherUser {
                await userViewModel.loadUserProfile(userId: otherUser.id)
                await userViewModel.loadStoryCount(userId: otherUser.id)
            }

            storiesViewModel.refreshBookStories(type: loadType)
            themesViewModel.refreshThemes(type: loadType)
        }
        
        .task {
            // 내 프로필은 이미 Contentview에서 로드해서 userViewModel의 currentUser에 할당된 상태
            if !isMyLibrary {
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        await userViewModel.loadUserProfile(userId: otherUser?.id)
                    }
                    group.addTask {
                        await userViewModel.loadStoryCount(userId: otherUser?.id)
                    }
                    group.addTask {
                        await storiesViewModel.loadBookStories(type: loadType)
                    }
                    // TODO: - 테마 뷰모델 async await로 만들면 여기에 병렬 실행 추가
                }
            }
            // 내 북스토리와 테마의 경우, 이미 ContentView 에서 불러온 상태
            themesViewModel.loadThemes(type: loadType)
        }
        
        // 친구 정보 초기화
        .onDisappear {
            userViewModel.currentOtherUser = nil
            userViewModel.currentOtherUserStoryCount = nil
        }
        
        // 여러 ViewModel 의 로딩 상태를 동시에 추적하고 로딩뷰 표시하는 모디파이어
        .progressOverlay(
            viewModels: userViewModel, storiesViewModel, themesViewModel,
            opacity: false
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    /// main 컨텐츠
    private var mainContent: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let friend = userViewModel.currentOtherUser {   // 친구 프로필
                        ProfileView(otherUser: friend)
                    } else {    // 내 프로필
                        ProfileView()
                    }
                    
                    LibraryTabButtonView(selectedView: $selectedView)
                        .id("tabSection")
                    
                    tabIndicator(height: 2, selectedView: selectedView, tabCount: 3)
                    contentSection
                    
                    Spacer().frame(height: 100)
                }
                .padding(.top, 10)
            }
            .onChange(of: selectedView) { _, _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo("tabSection", anchor: .top)
                }
            }
        }
    }
    
    // MARK: - CONTENT SECTION
    
    @ViewBuilder
    private var contentSection: some View {
        if selectedView == 0 {  // 북스토리 기록
            if storiesViewModel.bookStories(for: loadType).isEmpty {
                ContentUnavailableView("아직 기록이 없어요", systemImage: "tray", description: Text("지금 바로 나만의 문장을 기록해보세요"))
            } else {
                LibraryStoriesListView(isMy: isMyLibrary, loadType: loadType)
            }
        } else if selectedView == 1 {    // 테마 기록
            if themesViewModel.themes(for: loadType).isEmpty {
                ContentUnavailableView("아직 기록이 없어요", systemImage: "tray", description: Text("지금 바로 나만의 문장을 기록해보세요"))
            } else {
                LibraryThemesListView(isMy: isMyLibrary, loadType: loadType)
            }
        } else if selectedView == 2 {   // 키워드별 북스토리 기록
            KeywordGroupedStoriesView(isMy: isMyLibrary, loadType: loadType)
        }
    }
    
    @ViewBuilder
    private var navBarItems: some View {
        if isMyLibrary {
            myLibraryNavBarItems
        } else {
            friendLibraryNavBarItems
        }
    }
    
    private var myLibraryNavBarItems: some View {
        /// 내 라이브러리에는 '내 기록을 키워드로 찾을 수 있는 뷰와, 설정' 버튼
        HStack(spacing: 15) {
            ThemeToggleButton()

            NavigationLink(
                destination: SettingView()
                    .environmentObject(userViewModel)
                    .environmentObject(userAuthManager)
            ) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.brownLeather)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
    
    private var friendLibraryNavBarItems: some View {
        /// 친구 라이브러리에는 액션시트(신고/차단) 활성화 버튼
        Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .foregroundColor(.brownLeather)
                .font(.system(size: 16, weight: .medium))
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
            return Alert(
                title: Text("알림"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
    }
    
    @ViewBuilder
    private var actionSheetView: some View {
        Button("차단하기") {
            if userAuthManager.isUserAuthenticated {
                blockUser()
            } else {
                alertType = .loginRequired
                showAlert = true
            }
        }
        
        Button("신고하기", role: .destructive) {
            if userAuthManager.isUserAuthenticated {
                showReportSheet = true
            } else {
                alertType = .loginRequired
                showAlert = true
            }
        }
        
        Button("취소", role: .cancel) { }
    }
    
    private func blockUser() {
        guard let friend = userViewModel.currentOtherUser else { return }
        
        FollowService().updateFollowStatus(userId: friend.id, status: "BLOCKED") { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.alertType = .blocked
                    self.followViewModel.updateFollowStatus(userId: friend.id)
                    self.followViewModel.loadFollowCounts()
                }
            case .failure(let error):
                self.alertType = .blocked
                self.alertMessage = "오류: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
}
