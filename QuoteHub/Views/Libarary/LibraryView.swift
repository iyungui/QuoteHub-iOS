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
        if let friendId = otherUser?.id, !isMyLibrary {
            return LoadType.friend(friendId)  // 여기서 해당 사용자 id로 북스토리와 테마 불러오도록 모드 설정
        } else {
            return LoadType.my
        }
    }
    
    // 초기화
    init(otherUser: User? = nil) {
        self.otherUser = otherUser
    }
    
    // viewmodel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @Environment(BookStoriesViewModel.self) private var storiesViewModel
    @Environment(ThemesViewModel.self) private var themesViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(BlockReportViewModel.self) private var blockReportViewModel
    
    @EnvironmentObject private var tabController: TabController
    
    @State private var selectedView: Int = 0    // 테마, 스토리 탭
    
    // 알림 관련
    @State private var showAlert: Bool = false
    @State private var alertMessage: String? = nil
    
    // 신고 관련 (친구 프로필에서만 사용)
    @State private var showReportSheet = false
    @State private var showActionSheet = false

    @State private var stickyTabVisible = false
    @State private var originalTabPosition: CGFloat = 0

    // MARK: - BODY
    
    var body: some View {
        mainContent
        .backgroundGradient()
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
        .alert("알림", isPresented: $showAlert) {
            Button("확인") {}
        } message: {
            if alertMessage != nil {
                Text(alertMessage!)
            } else {    // 로그인 alert 인 경우 alertMessage 이 nil
                Text("이 기능을 사용하려면 로그인이 필요합니다.")
            }
        }
        
        // 차단, 신고하기 버튼 시트
        .confirmationDialog(Text(""), isPresented: $showActionSheet) { actionSheetView }
        
        // 유저 신고하기 창
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
        
        // 새로 고침
        .refreshable {
            if isMyLibrary {
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        await userViewModel.loadUserProfile(userId: nil)
                    }
                    group.addTask {
                        await userViewModel.loadStoryCount(userId: nil)
                    }
                    group.addTask {
                        await storiesViewModel.refreshBookStories(type: loadType)
                    }
                }
            } else if let otherUser = userViewModel.currentOtherUser, loadType == .friend(otherUser.id) {
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        await userViewModel.loadUserProfile(userId: otherUser.id)
                    }
                    group.addTask {
                        await userViewModel.loadStoryCount(userId: otherUser.id)
                    }
                    group.addTask {
                        await storiesViewModel.refreshBookStories(type: loadType)
                    }
                    group.addTask {
                        await themesViewModel.refreshThemes(type: loadType)
                    }
                }
            }
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
                    group.addTask {
                        await themesViewModel.loadThemes(type: loadType)
                    }
                }
            }
            // 내 북스토리와 테마의 경우, 이미 ContentView 에서 불러온 상태이므로 한번 더 부르지 않음
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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // 프로필 섹션
                            if let friend = userViewModel.currentOtherUser {
                                ProfileView(otherUser: friend)
                            } else {
                                ProfileView()
                            }
                            
                            // 탭 섹션 (원본)
                            VStack(spacing: 0) {
                                LibraryTabButtonView(selectedView: $selectedView)
                                    .id("tabSection")
                                TabIndicator(height: 3, selectedView: selectedView, tabCount: 3)
                            }
//                            .background(Color(.systemGroupedBackground))
                            .background(
                                GeometryReader { tabGeometry in
                                    Color.clear
                                        .onAppear {
                                            // 초기 위치 기록
                                            originalTabPosition = tabGeometry.frame(in: .global).minY
                                        }
                                        .onChange(of: tabGeometry.frame(in: .global).minY) { _, newY in
                                            updateStickyState(currentY: newY)
                                        }
                                }
                            )
                            .opacity(stickyTabVisible ? 0 : 1)
                            
                            // 콘텐츠 섹션
                            contentSection
                            
                            Spacer().frame(height: 100)
                        }
                        .padding(.top, 10)
                    }
                    .onChange(of: selectedView) { _, _ in
//                        if !stickyTabVisible {
                        // 이 조건을 빼면, 탭 전환 할 때마다 위로 스크롤 됨
                            withAnimation(.easeInOut(duration: 0.1)) {
                                proxy.scrollTo("tabSection", anchor: .top)
                            }
//                        }
                    }
                }
                
                // Sticky 탭 (조건부로만 표시)
                if stickyTabVisible {
                    VStack(spacing: 0) {
                        LibraryTabButtonView(selectedView: $selectedView)
                        TabIndicator(height: 3, selectedView: selectedView, tabCount: 3)
                    }
                    .background(Color(.systemGroupedBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
                    .zIndex(999)
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
            //            KeywordGroupedStoriesView(isMy: isMyLibrary, loadType: loadType)
            EmptyView()
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
        /// 내 라이브러리에는 '다크,라이트테마 토글버튼'와, 설정' 버튼
        HStack(spacing: 15) {
            ThemeToggleButton()
            
            NavigationLink(
                destination: SettingView()
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
    
    
    @ViewBuilder
    private var actionSheetView: some View {
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
    
    private func blockUser() async {
        guard let friend = userViewModel.currentOtherUser else { return }
        
        let isSuccess = await blockReportViewModel.blockUser(friend.id)
        alertMessage = isSuccess ? blockReportViewModel.successMessage : blockReportViewModel.errorMessage
        showAlert = true
    }
    
    private func getSafeAreaTop() -> CGFloat {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }

    private func updateStickyState(currentY: CGFloat) {
        let safeAreaTop = getSafeAreaTop()
        
        // 탭이 safe area에 도달하거나 넘어가면 sticky 활성화
        let shouldShowSticky = currentY <= safeAreaTop + 44
        
        if shouldShowSticky != stickyTabVisible {
            withAnimation(.none) {
                stickyTabVisible = shouldShowSticky
            }
        }
    }
}
