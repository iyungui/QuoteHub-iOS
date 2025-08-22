//
//  MainView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI


// MARK: - Main View

struct MainView: View {
    @EnvironmentObject private var tabController: TabManager
    @Environment(UserAuthenticationManager.self) private var authManager

    @State private var showAlert: Bool = false
    @State private var showActionButtons: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 메인 콘텐츠
                mainContent
                
                // 플로팅 액션 버튼들
                if showActionButtons {
                    FloatingActionOverlay(
                        showActionButtons: $showActionButtons,
                        activeSheet: $tabController.activeSheet,
                        showAlert: showLoginAlert
                    )
                    .zIndex(2)
                }
                
                // 커스텀 탭바
                VStack {
                    Spacer()
                    CustomTabbar(
                        selectedTab: $tabController.selectedTab,
                        showActionButtons: $showActionButtons,
                        showAlert: showLoginAlert
                    )
                }
                .zIndex(1)
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                if !authManager.isUserAuthenticated {
                    tabController.selectedTab = 2
                }
            }
        }
        // 로그인 필요 기능 시 알림
        .alert("", isPresented: $showAlert) {
            Button {
                authManager.showingLoginView = true
            } label: {
                Text("로그인")
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 기능을 사용하려면 로그인이 필요합니다.")
        }
        .fullScreenCover(item: $tabController.activeSheet) { sheet in
            destinationView(for: sheet)
        }
        .fullScreenCover(isPresented: .constant(authManager.showingLoginView)) {
            LoginView(isOnboarding: false)
        }
    }
    
    /// 메인뷰 - 홈뷰와 라이브러리뷰
    @ViewBuilder
    private var mainContent: some View {
        switch tabController.selectedTab {
        case 0:
            MyLibraryView()
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
}
