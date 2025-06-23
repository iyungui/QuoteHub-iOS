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

    @Environment(UserViewModel.self) private var userViewModel
    @Environment(UserAuthenticationManager.self) private var authManager
    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel
    @Environment(PublicBookStoriesViewModel.self) private var publicBookStoriesViewModel
    @Environment(MyThemesViewModel.self) private var myThemesViewModel
    @Environment(PublicThemesViewModel.self) private var publicThemesViewModel
    
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
                    // 인증된 사용자는 프로필, 내 북스토리와 내 테마 불러오기
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
                                await myBookStoriesViewModel.loadBookStories()
                            }
                            group.addTask {
                                await myThemesViewModel.loadThemes()
                            }
                        }
                    }
                    
                    // 인증되지 않은 사용자 + 인증된 사용자는 homeview에 표시될 public 북스토리와 테마 불러오기
                    await withTaskGroup(of: Void.self) { group in
                        group.addTask {
                            await publicBookStoriesViewModel.loadBookStories()
                        }
                        group.addTask {
                            await publicThemesViewModel.loadThemes()
                        }
                    }
                    
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


