//
//  UserAuthenticationManager.swift
//  QuoteHub
//
//  Created by 이융의 on 10/23/23.
//

import Foundation

final class UserAuthenticationManager: ObservableObject, LoadingViewModel {
    @Published var isUserAuthenticated: Bool = false
    @Published var isGuestMode: Bool = false
    @Published var showingLoginView: Bool = false
    @Published var isLoading: Bool = false
    @Published var loadingMessage: String?
    
    private let authService: AuthService
    private let tabController: TabController
    
    init(authService: AuthService = AuthService.shared,
         tabController: TabController = TabController()
    ) {
        self.authService = authService
        self.tabController = tabController
    }
    
    /// 애플 로그인 시 응답처리(토큰저장 및 상태 업데이트)
    @MainActor
    func handleAppleLogin(authCode: String) async -> Bool {
        isLoading = true
        
        do {
            // 서버로 Apple 로그인 요청(백그라운드 스레드)
            let response = try await authService.signInWithApple(authCode: authCode)
            
            guard response.success, let loginData = response.data else {
                print("Apple 로그인 실패: \(response.message)")
                return false
            }
            
            // 토큰 저장
            Task.detached { // 토큰 저장 완료되면 Task는 자동으로 메모리에서 해제
                try? await self.authService.saveTokens(loginData)
//                print("토큰 저장 완료: \(Thread.isMainThread)")
            }
            isUserAuthenticated = true
            showingLoginView = false
            
            tabController.selectedTab = 0   // 라이브러리뷰로 이동
            
            print("Apple 로그인 성공: \(loginData.user.nickname)")

        } catch {
            print("Apple 로그인 에러: \(error.localizedDescription)")
            return false
        }
        
        isLoading = false
        return true
    }
    
    /// 토큰 검증 및 토큰 재발급 (자동 로그인)
    // TODO: 하나의 메서드로 하기 보다는 기능 나누기
    @MainActor
    func validateAndRenewTokenNeeded() async {
        // 저장된 액세스 토큰이 있는지 먼저 확인
        guard authService.hasValidToken else {
            isUserAuthenticated = false
            return
        }
        
        // 저장된 액세스 토큰이 있어도 서버 통신을 통해 액세스토큰이 유효한지 확인
        do {
            // 네트워크 요청(백그라운드 스레드에서 실행)
            let response = try await authService.validateAndRenewToken()
            
            guard response.success, let validationData = response.data else {
                // 토큰 검증 실패
                isUserAuthenticated = false
                showingLoginView = true
                return
            }
            
            // 토큰이 이미 유효함 (토큰 갱신 필요없음 -> 바로 로그인)
            if validationData.valid {
                isUserAuthenticated = true
                print("토큰 유효 - 자동 로그인 성공")
                
            // 액세스 토큰이 만료되었지만 리프레시 토큰을 통해 토큰 재발급에 성공하였다면
            } else if let newAccessToken = validationData.accessToken,
                    let newRefreshToken = validationData.refreshToken {
                // 새 토큰 Keychain에 업데이트
                Task.detached { // 토큰 저장 완료되면 Task는 자동으로 메모리에서 해제
                    try? await self.authService.updateBothTokens(
                        newAccessToken: newAccessToken,
                        newRefreshToken: newRefreshToken
                    )
                }
                isUserAuthenticated = true
                print("새 토큰 발급 - 자동 로그인 성공")
            } else {
                // 액세스토큰도 만료되었고, validateAndRenewToken 요청을 했지만 리프레시 토큰도 만료되었을 때 -> 토큰 갱신 실패
                isUserAuthenticated = false
                showingLoginView = true
                print("토큰 갱신 실패 - 재로그인 필요")
            }
        } catch {
            print("토큰 검증 에러: \(error.localizedDescription)")
            isUserAuthenticated = false
            showingLoginView = true
        }
    }
    
    /// 로그아웃
    @MainActor
    func logout() async {
        isLoading = true
        Task.detached {
            try? await self.authService.clearAllTokens()
        }
        // 상태 초기화 (온보딩뷰로 이동)
        goToOnboardingView()
        
        print("로그아웃 성공")
        isLoading = false
    }
    
    /// 계정 탈퇴
    @MainActor
    func revokeAccount() async -> Bool {
        isLoading = true
        
        do {
            // 백엔드 서버에 apple token 해제 및 DB에서 유저 관련 정보 및 유저가 올린 게시물까지 삭제 요청
            let response = try await authService.revokeAccount()
            
            guard response.success, let revokeData = response.data, revokeData.revoked else {
                print("계정 탈퇴 실패: \(response.message)")
                isLoading = false
                return false
            }
            
            // keychain에 저장된 토큰도 삭제
            Task.detached {
                try? await self.authService.clearAllTokens()
            }
            
            // 상태 초기화 (온보딩뷰로 이동)
            goToOnboardingView()
            
            print("계정 탈퇴 성공")
            isLoading = false
            return true
        } catch {
            print("계정 탈퇴 실패: \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
    
    @MainActor
    private func goToOnboardingView() {
        isUserAuthenticated = false
        isGuestMode = false
        showingLoginView = false
    }
}
