//
//  MainView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

// MARK: - for plus button sheet
enum ActiveSheet: Identifiable {
    case search, theme
    
    var id: String {
        switch self {
        case .search: return "search"
        case .theme: return "theme"
        }
    }
}

// MARK: - Main View

struct MainView: View {
    @State private var selectedTab: Int = 2
    @State private var showAlert: Bool = false
    @State private var showActionButtons: Bool = false
    @State private var activeSheet: ActiveSheet?
    
    @EnvironmentObject private var authManager: UserAuthenticationManager
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 메인 콘텐츠
                mainContent
                
                // 플로팅 액션 버튼들
                if showActionButtons {
                    FloatingActionOverlay(
                        showActionButtons: $showActionButtons,
                        activeSheet: $activeSheet,
                        showAlert: showLoginAlert
                    )
                    .zIndex(2)
                }
                
                // 커스텀 탭바
                VStack {
                    Spacer()
                    CustomTabbar(
                        selectedTab: $selectedTab,
                        showActionButtons: $showActionButtons,
                        showAlert: showLoginAlert
                    )
                }
                .zIndex(1)
            }
            .navigationBarBackButtonHidden()
            .onAppear(perform: onAppear)
        }
        .alert("", isPresented: $showAlert) {
            Button {
                authManager.showingLoginView = true
            } label: {
                Text("로그인").font(.scoreDreamBody)
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 기능을 사용하려면 로그인이 필요합니다.").font(.scoreDreamBody)
        }
        .fullScreenCover(item: $activeSheet) { sheet in
            destinationView(for: sheet)
        }
        .fullScreenCover(isPresented: $authManager.showingLoginView) {
            LoginView(isOnboarding: false)
        }
    }
    
    /// 메인뷰 - 홈뷰와 라이브러리뷰
    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case 0:
            LibraryView(user: nil)
        case 2:
            HomeView()
        default:
            EmptyView()
        }
    }
    
    /// 책 검색뷰와 테마 만들기뷰
    @ViewBuilder
    private func destinationView(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .search:
            SearchBookView()
        case .theme:
            NavigationStack {
                CreateThemeView(mode: .fullScreenSheet)
            }
        }
    }
    
    private func showLoginAlert() {
        showAlert = true
    }
    
    // TODO: - onAppear 없애기
    private func onAppear() {
        if authManager.isUserAuthenticated {
            selectedTab = 0
            userViewModel.getProfile(userId: nil)
        }
    }
}
