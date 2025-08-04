//
//  UserAuthenticationManager.swift
//  QuoteHub
//
//  Created by 이융의 on 10/23/23.
//

import Foundation

// TODO: - refac

@Observable
final class UserAuthenticationManager: LoadingViewModel {
    var isUserAuthenticated: Bool = false
    var isGuestMode: Bool = false
    var showingLoginView: Bool = false  // 게스트모드 상태에서 바로 로그인 창으로 네비게이션하기 위한 프로퍼티
    var isLoading: Bool = false
    var loadingMessage: String?
    
    // 닉네임 설정 관련 상태 추가
    var showingNicknameSetup: Bool = false {
        didSet {
            print("show nickname: \(showingNicknameSetup)")
        }
    }
    
    var showingFontSetup: Bool = false
    
    var initialNickname: String = ""
    
    private let authService: AuthService
    private let tabController: TabController
    
    init(authService: AuthService = AuthService.shared,
         tabController: TabController = TabController()
    ) {
        self.authService = authService
        self.tabController = tabController
    }
    
    /// 애플 로그인 시 응답처리 (토큰저장)
    @MainActor
    func handleAppleLogin(authCode: String) async -> (success: Bool, isNewUser: Bool, nickname: String) {
        isLoading = true
        
        do {
            // 서버로 Apple 로그인 요청(백그라운드 스레드)
            let response = try await authService.signInWithApple(authCode: authCode)
            
            guard response.success, let loginData = response.data else {
                print("Apple 로그인 실패: \(response.message)")
                return (false, false, "")
            }
            
            try authService.saveTokens(loginData)
            
            print("Apple 로그인 성공: \(loginData.user.nickname)")
            return (true, loginData.isNewUser, loginData.user.nickname)
            
        } catch {
            print("Apple 로그인 에러: \(error.localizedDescription)")
            return (false, false, "")
        }
    }
    
    /// 닉네임 설정 화면 표시
    @MainActor
    func showNicknameSetup(nickname: String) {
        initialNickname = nickname
        showingNicknameSetup = true
        showingLoginView = false
        isLoading = false
    }
    
    /// 로그인 완료 후 라이브러리뷰 이동 (데이터 로딩은 외부에서 처리)
    @MainActor
    func completeLoginProcess() {
        showingFontSetup = false
        
        goToLibraryView()
        isLoading = false
    }
    
    @MainActor
    func goToFontSettingView() {
        showingNicknameSetup = false
        showingFontSetup = true
        isLoading = false
    }
    
    /// 토큰 검증 및 토큰 재발급 후 메인뷰로 이동 (자동 로그인)
    @MainActor
    func validateAndRenewTokenNeeded() async {
        // 리프레시 토큰이 있다면 무조건 서버에 검증 요청
        
        // 리프레시 토큰이 아예 없다면 로그아웃
        guard authService.hasRefreshToken else {
            isUserAuthenticated = false
            return
        }
        
        // 저장된 액세스 토큰이 있어도 서버 통신을 통해 액세스토큰 혹은 리프레시 토큰이 유효한지 확인
        do {
            // 네트워크 요청(백그라운드 스레드에서 실행)
            let response = try await authService.validateAndRenewToken()
            print("validateAndRenewToken log: \(response.message)")
            
            guard response.success, let validationData = response.data else {
                // 토큰 검증 실패 (액세스, 리프레시 토큰 모두 만료된 경우)
                isUserAuthenticated = false
                return
            }
            
            // 액세스 토큰이 아직 유효함 (토큰 갱신 필요없음 -> 바로 로그인)
            if validationData.valid {
                goToLibraryView()
                print("토큰 유효 - 자동 로그인 성공")
                
            // 액세스 토큰은 만료되었지만 리프레시 토큰을 통해 토큰 재발급에 성공하였다면
            } else if let newAccessToken = validationData.accessToken,
                    let newRefreshToken = validationData.refreshToken {
                // 새 토큰 Keychain에 업데이트
                Task.detached { // 토큰 저장 완료되면 Task는 자동으로 메모리에서 해제
                    try? await self.authService.updateBothTokens(
                        newAccessToken: newAccessToken,
                        newRefreshToken: newRefreshToken
                    )
                }
                
                goToLibraryView()
                print("새 토큰 발급 - 자동 로그인 성공")
            } else {
                // validateAndRenewToken 요청을 했지만 액세스와 리프레시 토큰 모두 만료되었을 때 -> 토큰 갱신 실패
                isUserAuthenticated = false
                print("토큰 갱신 실패 - 재로그인 필요")
            }
        } catch {
            print("토큰 검증 에러: \(error.localizedDescription)")
            isUserAuthenticated = false
        }
    }
    
    /// 로그아웃
    @MainActor
    func logout() async {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        Task.detached {
            try? await self.authService.clearAllTokens()
        }
        // 상태 초기화 (온보딩뷰로 이동)
        goToOnboardingView()
        
        print("로그아웃 성공")
    }
    
    /// 계정 탈퇴
    @MainActor
    func revokeAccount() async -> Bool {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            // 백엔드 서버에 apple token 해제 및 DB에서 유저 관련 정보 및 유저가 올린 게시물까지 삭제 요청
            let response = try await authService.revokeAccount()
            
            guard response.success, let revokeData = response.data, revokeData.revoked else {
                print("계정 탈퇴 실패: \(response.message)")
                return false
            }
            
            // keychain에 저장된 토큰도 삭제
            Task.detached {
                try? await self.authService.clearAllTokens()
            }
            
            // 상태 초기화 (온보딩뷰로 이동)
            goToOnboardingView()
            
            print("계정 탈퇴 성공")
            return true
        } catch {
            print("계정 탈퇴 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    @MainActor
    private func goToOnboardingView() {
        isUserAuthenticated = false
        isGuestMode = false
        showingLoginView = false
        showingNicknameSetup = false  // 닉네임 설정 상태도 초기화
        print("온보딩뷰로 이동!")
    }
    
    @MainActor
    func goToLibraryView() {
        tabController.selectedTab = 0   // 라이브러리뷰로 이동

        isUserAuthenticated = true
        showingLoginView = false
        showingNicknameSetup = false  // 닉네임 설정 상태도 초기화
        showingFontSetup = false
        
        print("라이브러리뷰로 이동!")
    }
}
