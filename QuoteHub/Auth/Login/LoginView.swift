//
//  LoginView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import SwiftUI
import AuthenticationServices
import Alamofire

struct LoginView: View {
    /// 온보딩뷰를 통해 LoginView로 접근했다면 true, 그 외 뷰에서 LoginView로 왔다면 false
    let isOnboarding: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: UserAuthenticationManager
    
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
    @EnvironmentObject var authManager: UserAuthenticationManager
    
    var body: some View {
        SignInWithAppleButton(
            .continue,
            onRequest: { request in
                request.requestedScopes = [.email, .fullName]
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
                await authManager.handleAppleLogin(authCode: authCodeString)
            }
        case .failure(let error):
            print("Apple 로그인 실패: \(error.localizedDescription)")
        }
    }
}

#Preview {
    LoginView(isOnboarding: true).environmentObject(UserAuthenticationManager())
}
