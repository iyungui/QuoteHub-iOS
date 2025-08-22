//
//  UserViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/02.
//

import SwiftUI

@MainActor
@Observable
final class UserViewModel: LoadingViewModelProtocol {
    
    // 현재 로그인한 사용자
    var currentUser: User?
    var currentUserStoryCount: Int?
    
    // 현재 보고 있는 다른 사용자 (친구 프로필용)
    var currentOtherUser: User?
    var currentOtherUserStoryCount: Int?
    
    // 로딩 상태
    var isLoadingProfile: Bool = false
    var isLoadingStoryCount: Bool = false

    var isLoading: Bool {
        // 프로필, 스토리 개수 둘 중에 하나만 false(로딩중)이면 전체 로딩 상태는 false로 되도록
        isLoadingProfile || isLoadingStoryCount
    }
    
    var loadingMessage: String?
    
    // 메시지(일단 지금은 메시지는 덜 중요하므로 그대로 둠 - (race condition 발생 가능성 있다!)
    var errorMessage: String?
    var successMessage: String?
    
    // 의존성 주입
    private var userService: UserServiceProtocol
    
    // 초기화
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
}

extension UserViewModel {
    
    /// 사용자 프로필 조회 (로그인한 사용자는 currentUesr 에, 다른 사용자는 currentOtherUser에 업데이트)
    func loadUserProfile(userId: String?) async {
        isLoadingProfile = true
        loadingMessage = "로딩 중..."
        clearMessage()
        
        // 함수 종료 후 로딩 상태 초기화
        defer {
            isLoadingProfile = false
            loadingMessage = nil
        }
        
        do {
            // 네트워크 요청(백그라운드에서)
            let response = try await userService.getProfile(userId: userId)
            
            if response.success {
                successMessage = response.message

                if userId == nil {
                    currentUser = response.data
                } else {
                    currentOtherUser = response.data
                }
            } else {
                errorMessage = response.message
            }
                
        } catch {
            handleError(error)
        }
    }
    
    /// currentUser 프로필 업데이트
    func updateProfile(
        nickname: String,
        profileImage: UIImage? = nil,
        statusMessage: String
    ) async -> Bool {
        
        // 입력 값 검증
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStatusMessage = statusMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedNickname.isEmpty else {
            errorMessage = "닉네임을 입력해주세요."
            return false
        }
        
        isLoadingProfile = true
        loadingMessage = "로딩 중..."
        clearMessage()
        
        defer {
            isLoadingProfile = false
            loadingMessage = nil
        }
        
        do {
            let response = try await userService.updateProfile(
                nickname: trimmedNickname,
                profileImage: profileImage,  // nil 일 수 있음
                statusMessage: trimmedStatusMessage
            )
            
            if response.success {
                // 업데이트된 사용자 정보 저장
                currentUser = response.data
                successMessage = response.message
                return true
            } else {
                errorMessage = response.message
                return false
            }
        } catch {
            handleError(error)
            return false
        }
    }
    
    /// 사용자 북스토리 기록 개수 조회
    func loadStoryCount(userId: String?) async {
        isLoadingStoryCount = true
        loadingMessage = "로딩 중..."
        clearMessage()
        
        defer {
            isLoadingStoryCount = false
            loadingMessage = nil
        }
        
        do {
            // 네트워크 요청 (백그라운드에서)
            let response = try await userService.getUserBookStoryCount(userId: userId)
            
            if response.success {
                successMessage = response.message
                
                if userId == nil {
                    currentUserStoryCount = response.data
                } else {
                    currentOtherUserStoryCount = response.data
                }
                
            } else {
                errorMessage = response.message
            }
        } catch {
            handleError(error)
        }
    }
    
}

extension UserViewModel {
    
    /// 메시지 초기화
    private func clearMessage() {
        errorMessage = nil
        successMessage = nil
    }
    
    /// 에러 처리
    private func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다.: \(error.localizedDescription)"
        }
    }
}
