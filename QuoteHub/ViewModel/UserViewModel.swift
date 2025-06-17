//
//  UserViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/02.
//

import SwiftUI

@MainActor
@Observable
final class UserViewModel: LoadingViewModel {
    
    // 현재 사용자
    var currentUser: User?
    
    // 사용자 북스토리 개수
    var storyCount: Int?
    
    // 로딩 상태
    var isLoading: Bool = false
    var loadingMessage: String?
    
    // 메시지
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
    
    /// 현재 로그인한 사용자 프로필 조회 (currentUesr 에 업데이트)
    func loadCurrentUserProfile(userId: String?) async {
        isLoading = true
        loadingMessage = "프로필을 불러오는 중..."
        clearMessage()
        
        // 함수 종료 후 로딩 상태 초기화
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            // 네트워크 요청(백그라운드에서)
            let response = try await userService.getProfile(userId: nil)
            
            if response.success {
                currentUser = response.data
                successMessage = response.message
            } else {
                errorMessage = response.message
            }
                
        } catch {
            handleError(error)
        }
    }
    
    /// 특정 사용자 프로필 조회
    func loadUserProfile(userId: String) async -> User? {
        isLoading = true
        loadingMessage = "프로필을 불러오는 중..."
        clearMessage()

        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            // 네트워크 요청 (백그라운드에서)
            let response = try await userService.getProfile(userId: userId)
            
            if response.success {
                successMessage = response.message
                return response.data
            } else {
                errorMessage = response.message
                return nil
            }
        } catch {
            handleError(error)
            return nil
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
        
        isLoading = true
        loadingMessage = "프로필을 업데이트하는 중..."
        clearMessage()
        
        defer {
            isLoading = false
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
    
    func loadStoryCount(userId: String?) async {
        isLoading = true
        loadingMessage = "로딩 중..."
        clearMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            // 네트워크 요청 (백그라운드에서)
            let response = try await userService.getUserBookStoryCount(userId: userId)
            
            if response.success {
                successMessage = response.message
                storyCount = response.data
            } else {
                errorMessage = response.message
            }
        } catch {
            handleError(error)
        }
    }
    
}

// MARK: - Helper Methods (다른 뷰모델에서 범용적으로 사용)

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
