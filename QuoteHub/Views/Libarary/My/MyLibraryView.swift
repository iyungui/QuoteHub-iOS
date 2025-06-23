//
//  MyLibraryView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct MyLibraryView: View {
    
    // MARK: - VIEWMODELS
    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel

    @Environment(MyThemesViewModel.self) private var myThemesViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(UserAuthenticationManager.self) private var userAuthManager
    @EnvironmentObject private var tabController: TabController
    
    // MARK: - State
    @State private var selectedTab: LibraryTab = .stories
    @State private var showAlert = false
    @State private var alertMessage: String?
    
    // MARK: - Body
    
    var body: some View {
        LibraryBaseView(
            selectedTab: $selectedTab,
            showKeywords: true,
            profileSection: {
                LibraryProfileSection(
                    user: userViewModel.currentUser,
                    storyCount: userViewModel.currentUserStoryCount ?? 0,
                    isMyProfile: true
                )
            },
            contentSection: {
                LibraryContentSection(
                    selectedTab: selectedTab,
                    storiesView: {
                        MyLibraryStoriesView()
                    },
                    themesView: {
                        MyLibraryThemesView()
                    },
                    keywordsView: {
                        MyLibraryKeywordsView()
                    }
                )
            },
            navigationBarItems: {
                MyLibraryNavigationItems()
            }
        )
        .navigationDestination(isPresented: $tabController.shouldNavigateToStoryDetail) {
            if let story = tabController.selectedStory {
                MyBookStoryDetailView(story: story)
            }
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인") {}
        } message: {
            if let alertMessage = alertMessage {
                Text(alertMessage)
            } else {    // alertMessage 가 nil 이라면, 로그인 요구 alert 이므로
                Text("이 기능을 사용하려면 로그인이 필요합니다.")
            }
        }
        .refreshable {
            await refreshMyLibrary()
        }
//        .task {
//            /// 내 라이브러리의 경우 ContentView or LoginView 에서 로드된 상태
//        }
        .progressOverlay(viewModels: userViewModel, myBookStoriesViewModel, myThemesViewModel, opacity: false)
    }
    
    private func refreshMyLibrary() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await userViewModel.loadUserProfile(userId: nil)
            }
            group.addTask {
                await userViewModel.loadStoryCount(userId: nil)
            }
            group.addTask {
                await myBookStoriesViewModel.refreshBookStories()
            }
            group.addTask {
                // TODO: - refac
                await myThemesViewModel.refreshThemes()
            }
        }
    }
}
