//
//  LibraryView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import SDWebImageSwiftUI

/// 내 라이브러리, 친구 라이브러리 모두 LibraryView 로 접근
/// 친구 라이브러리의 경우 user 파라미터를 추가로 받아서 구분
struct LibraryView: View {
    
    // MARK: - Properties
    
    // 친구 프로필인지 구분하는 프로퍼티
    let user: User?
    
    /// 내 라이브러리인지 친구 라이브러리인지 구분
    var isMyLibaray: Bool {
        return user == nil
    }   // friendId 가 nil 이면, 내 라이브러리
    
    private var currentUser: User? {
        return user ?? userViewModel.user
    }

    var loadType: LoadType {
        if !isMyLibaray {
            guard let userId = user?.id else { return LoadType.my }
            return LoadType.friend(userId)
        } else {
            return LoadType.my
        }
    }
    
    // 초기화
    init(user: User? = nil) {
        self.user = user
        self._followViewModel = StateObject(wrappedValue: FollowViewModel(userId: user?.id))
    }
    
    // viewmodel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel

    // 신고, 차단 기능을 위한
    @StateObject private var followViewModel: FollowViewModel

    @State private var selectedView: Int = 0    // 테마, 스토리 탭

    @Environment(\.colorScheme) var colorScheme // 다크모드 지원

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
            // 친구의 라이브러리이고 해당 친구가 차단된 사용자일 때
            if !isMyLibaray && followViewModel.isBlocked {
                ContentUnavailableView("차단된 사용자", systemImage: "person.crop.circle.badge.xmark.fill", description: Text("설정의 차단 목록을 확인해주세요."))
            } else {
                mainContent
            }
        }
        // 툴바
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                currentNavBarItems
            }
        }
        
        // 알림창 (비로그인, 오류, 블럭?)
        .alert(isPresented: $showAlert) { alertView }
        
        // 차단, 신고하기 버튼 시트
        .confirmationDialog(Text(""), isPresented: $showActionSheet) { actionSheetView }
        
        // 유저 신고하기 창
        .sheet(isPresented: $showReportSheet) {
            if let friend = user {
                UserReportSheetView(
                    userId: friend.id,
                    reportReason: $reportReason
                ).environmentObject(followViewModel)
            }
        }
        
        // 새로 고침
        .refreshable {
            await refreshContent(type: loadType)
        }
        .onAppear {
            onAppear(type: loadType)
        }
        // 여러 ViewModel 의 로딩 상태를 동시에 추적하고 로딩뷰 표시하는 모디파이어
        .progressOverlay(
            viewModels: userViewModel, storiesViewModel, themesViewModel,
            opacity: true
        )
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Private Views
    
    /// main 컨텐츠
    private var mainContent: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let friend = user {   // 친구 프로필
                        ProfileView(user: friend)
                            .environmentObject(followViewModel)
                            .environmentObject(userAuthManager)
                            .environmentObject(userViewModel)
                            .environmentObject(storiesViewModel)
                            .environmentObject(themesViewModel)

                    } else {    // 내 프로필
                        ProfileView()
                            .environmentObject(followViewModel)
                            .environmentObject(userAuthManager)
                            .environmentObject(userViewModel)
                            .environmentObject(storiesViewModel)
                            .environmentObject(themesViewModel)
                    }
                    
                    LibraryTabButtonView(selectedView: $selectedView)
                        .id("tabSection")
                    
                    tabIndicator(height: 2, selectedView: selectedView)
                    
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
        if selectedView == 0 {  // 테마 기록
            if themesViewModel.themes(for: loadType).isEmpty {
                ContentUnavailableView("아직 기록이 없어요", systemImage: "tray", description: Text("지금 바로 나만의 문장을 기록해보세요"))
            } else {
                LibraryThemesListView(isMy: isMyLibaray, loadType: loadType)
                    .environmentObject(themesViewModel)
                    .environmentObject(userViewModel)
            }
            
        } else {    // 스토리 기록
            if storiesViewModel.bookStories(for: loadType).isEmpty {
                ContentUnavailableView("아직 기록이 없어요", systemImage: "tray", description: Text("지금 바로 나만의 문장을 기록해보세요"))
            } else {
                LibraryStoriesListView(isMy: isMyLibaray, loadType: loadType)
                    .environmentObject(storiesViewModel)
                    .environmentObject(userAuthManager)
            }
        }
    }
    
    @ViewBuilder
    private var currentNavBarItems: some View {
        if isMyLibaray {
            myLibraryNavBarItems
        } else {
            friendLibraryNavBarItems
        }
    }
    
    private var myLibraryNavBarItems: some View {
        /// 내 라이브러리에는 '내 기록을 키워드로 찾을 수 있는 뷰와, 설정' 버튼
        HStack {
            NavigationLink(
                destination: SearchStoryByKeywordView(type: loadType)
                    .environmentObject(storiesViewModel)
                    .environmentObject(userViewModel)
            ) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.systemGray))
                    .frame(width: 25, height: 25)
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
    
    private func refreshContent(type: LoadType) async {
        userViewModel.getProfile(userId: currentUser?.id)
        userViewModel.loadStoryCount(userId: currentUser?.id)
        followViewModel.setUserId(currentUser?.id)
        followViewModel.loadFollowCounts()

        storiesViewModel.refreshBookStories(type: type)
        themesViewModel.refreshThemes(type: type)
                
        // 친구 프로필인 경우 팔로우 상태 업데이트
        if let friend = user {
            followViewModel.updateFollowStatus(userId: friend.id)
        }
    }
    
    private func onAppear(type: LoadType) {
        userViewModel.getProfile(userId: currentUser?.id)
        userViewModel.loadStoryCount(userId: currentUser?.id)
        followViewModel.setUserId(currentUser?.id)
        followViewModel.loadFollowCounts()
        
        storiesViewModel.loadBookStories(type: type)
        themesViewModel.loadThemes(type: type)
        
        // 친구 프로필인 경우 팔로우 상태 업데이트
        if let friend = user {
            followViewModel.updateFollowStatus(userId: friend.id)
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
        guard let friend = user else { return }
        
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
