//
//  MainView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case search, theme
    
    var id: String {
        switch self {
        case .search: return "search"
        case .theme: return "theme"
        }
    }
}

struct MainView: View {
    @State private var selectedTab: Int = 0
    @State private var showAlert: Bool = false
    @State private var showActionButtons: Bool = false
    @State private var activeSheet: ActiveSheet?
    
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 메인 콘텐츠
                mainContent
                    .environmentObject(userAuthManager)
                    .environmentObject(userViewModel)
                    .environmentObject(storiesViewModel)
                    .environmentObject(themesViewModel)
                
                // 플로팅 액션 버튼들
                if showActionButtons {
                    FloatingActionOverlay(
                        showActionButtons: $showActionButtons,
                        activeSheet: $activeSheet,
                        showAlert: showLoginAlert
                    )
                    .environmentObject(userAuthManager)
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
                    .environmentObject(userAuthManager)
                }
                .zIndex(1)
            }
            .navigationBarBackButtonHidden()
            .onAppear(perform: onAppear)
        }
        .alert("", isPresented: $showAlert) {
            Button {
                userAuthManager.showingLoginView = true
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
        .fullScreenCover(isPresented: $userAuthManager.showingLoginView) {
            LoginView(isOnboarding: false).environmentObject(userAuthManager)
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case 0:
            HomeView()
        case 2:
            LibraryView(user: nil)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func destinationView(for sheet: ActiveSheet) -> some View {
        switch sheet {
        case .search:
            SearchBookView()
                .environmentObject(storiesViewModel)
                .environmentObject(userAuthManager)
        case .theme:
            MakeThemaView()
                .environmentObject(themesViewModel)
        }
    }
    
    private func showLoginAlert() {
        showAlert = true
    }
    
    // TODO: - onAppear 없애기
    private func onAppear() {
        if userAuthManager.isUserAuthenticated {
            userViewModel.getProfile(userId: nil)
        }
    }
}
