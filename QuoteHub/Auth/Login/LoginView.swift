//
//  LoginView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    /// 온보딩뷰를 통해 LoginView로 접근했다면 true, 그 외 뷰에서 LoginView로 왔다면 false
    let isOnboarding: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(UserAuthenticationManager.self) private var authManager
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Spacer()
            
            Text("지금 바로 나만의 문장을 기록해보세요.")
                .font(.scoreDreamTitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Text("문장을 모아 지혜를 담다, 문장모아")
                .font(.scoreDream(.medium, size: .body))
                .padding(.horizontal, 20)

            Spacer().frame(height: 35)

            AppleLoginButton()
              .frame(width: 280, height: 60, alignment: .center)
              .signInWithAppleButtonStyle(colorScheme == .light ? .black : .whiteOutline)
            
            Button {
                // 온보딩 화면에서만 게스트모드 활성화 버튼 추가
                if isOnboarding {
                    authManager.isGuestMode = true
                } else {
                    // 그 외 뷰에서는 그냥 뒤로가기
                    authManager.showingLoginView = false
                    dismiss()
                }
            } label: {
                Text("나중에 하기")
                    .font(.scoreDream(.regular, size: .callout))
                    .underline()
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(!isOnboarding)
        // 로그인 시 loading progress overlay 표시
        .progressOverlay(viewModel: authManager, opacity: false)
    }
}

struct AppleLoginButton: View {
    @Environment(UserAuthenticationManager.self) private var authManager
    @Environment(UserViewModel.self) var userViewModel
    
    @Environment(MyBookStoriesViewModel.self) private var myBookStoriesViewModel
    @Environment(PublicBookStoriesViewModel.self) private var publicBookStoriesViewModel
    @Environment(MyThemesViewModel.self) private var myThemesViewModel

    var body: some View {
        SignInWithAppleButton(
            .continue,
            onRequest: { request in
                request.requestedScopes = []
            },
            onCompletion: { result in
                handleAuthorization(result)
            }
        )
    }
    
    func handleAuthorization(_ result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let authResults):
            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                  let authorizationCode = appleIDCredential.authorizationCode,
                  let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
                print("Apple 인증 데이터 파싱 실패")
                return
            }
            
            // User Auth Manager에서 네트워크 요청 및 로그인 처리
            Task {
                let result = await authManager.handleAppleLogin(authCode: authCodeString)
                
                if result.success {
                    if result.isNewUser {
                        // 새 사용자 - 닉네임 설정 화면으로
                        await MainActor.run {
                            authManager.showNicknameSetup(nickname: result.nickname)
                        }
                    } else {
                        // 기존 사용자 - 데이터 로딩 후 라이브러리뷰로
                        await loadLoginUserData()
                        await MainActor.run {
                            authManager.completeLoginProcess()
                        }
                    }
                } else {
                    await MainActor.run {
                        authManager.isLoading = false
                    }
                }
            }
        case .failure(let error):
            print("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }
    
    private func loadLoginUserData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await userViewModel.loadUserProfile(userId: nil)
            }
            group.addTask {
                await userViewModel.loadStoryCount(userId: nil)
            }
            group.addTask {
                await myBookStoriesViewModel.loadBookStories()
            }
            group.addTask {
                await publicBookStoriesViewModel.loadBookStories()
            }
            group.addTask {
                await myThemesViewModel.loadThemes()
            }
        }
    }
}

#Preview {
    LoginView(isOnboarding: true)
        .environmentObject(UserAuthenticationManager())
}
