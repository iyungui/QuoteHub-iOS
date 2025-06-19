//
//  ContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/06.
//

import SwiftUI

// ContentView 에서는 앱 화면 분기처리

struct ContentView: View {
    @State private var versionManager = AppVersionManager()

    @EnvironmentObject private var authManager: UserAuthenticationManager
    @Environment(BookStoriesViewModel.self) private var storiesViewModel
    @Environment(ThemesViewModel.self) private var themesViewModel
    @Environment(UserViewModel.self) private var userViewModel

    @State private var isSplashView = true  // 런치스크린 표시

    var body: some View {
        if isSplashView {
            LaunchScreenView()
                // LaunchScreenView 나타날 때 토큰 검증 및 앱 버전 체크
                // TODO: - 여기서 .task 로 (유저, 북스토리, 테마) 데이터 모델을 미리 로드하고 전달하기.
                .task {
                    // 각 작업이 독립적이므로 병렬 실행
                    await withTaskGroup(of: Void.self) { group in
                        // 현재 앱스토어 버전 확인
                        group.addTask {
                            await versionManager.checkVersionFromAppStore()
                        }
                        // 인증 확인
                        group.addTask {
                            await authManager.validateAndRenewTokenNeeded()
                        }
                    }
                    // 여기까지 오면 isUserAuthenticated 여부 확인됨.
                    // 인증된 사용자는 프로필, 게시물 불러오고 mainView로 이동
                    if authManager.isUserAuthenticated {
                        await withTaskGroup(of: Void.self) { group in
                            // 현재 사용자 정보 가져오기 (유저모델의 currentUser 업데이트)
                            group.addTask {
                                await userViewModel.loadUserProfile(userId: nil)
                            }
                            // 현재 사용자 정보의 북스토리 카운트도 동시에 가져오기 (storyCount 업데이트)
                            group.addTask {
                                await userViewModel.loadStoryCount(userId: nil)
                            }
                            
                            group.addTask {
                                await storiesViewModel.loadBookStories(type: .my)
                            }
                            group.addTask {
                                await themesViewModel.loadThemes(type: .my)
                            }
                            
                        }
                    }
                    // public 북스토리, 테마는 HomeView에서 load
                    // 인증된 사용자 아니면 바로 isSplashView를 false로
                    
                    // 지연 (나중에 지울 코드)
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    withAnimation {
                        isSplashView = false
                    }
                }
        } else {
            Group {
                // 앱을 시작할 때, 인증된 사용자라면 또는 게스트로그인 사용자라면 MainView로 가고,
                // 둘 다 해당되지 않는다면 OnboardingView 로 이동
                if authManager.isUserAuthenticated || authManager.isGuestMode {
                    MainView()
                } else {
                    OnboardingView()
                }
            }
            // 앱 업데이트 필요 시, alert으로 유도
            .alert("업데이트 필요", isPresented: $versionManager.showUpdateAlert) {
                Button("확인") {
                    versionManager.goUpdate()
                    versionManager.closeApp()
                }
            } message: {
                Text("새 버전 \(versionManager.latestVersion)이 출시되었습니다.\n앱을 계속 사용하려면 업데이트해주세요.")
            }
        }
    }
}


