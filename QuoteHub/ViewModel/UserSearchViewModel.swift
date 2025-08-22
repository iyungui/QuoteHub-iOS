//
//  UserSearchViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 11/16/23.
//

import Foundation

@MainActor
@Observable
final class UserSearchViewModel: LoadingViewModelProtocol {
    
    var users: [User]?
    
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

extension UserSearchViewModel {
    
    func searchUser(nickname: String) async {
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
            let response = try await userService.searchUser(nickname: nickname)
            
            if response.success {
                users = response.data
                successMessage = response.message
            } else {
                errorMessage = response.message
            }
            
        } catch {
            handleError(error)
        }
        
    }
}
    /*
    func searchUser(nickname: String) {
        print("검색 시작: \(nickname)")
        isLoading = true
        errorMessage = nil

        userService.searchUser(nickname: nickname) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                print("검색 완료")
                switch result {
                case .success(let searchUserResponse):
                    print("검색 성공: \(String(describing: searchUserResponse.data?.count)) 명의 사용자 찾음")
                    self?.users = searchUserResponse.data ?? []
                case .failure(let error):
                    print("검색 실패: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
     */



extension UserSearchViewModel {
    
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
