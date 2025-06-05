//
//  UserViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/02.
//

import SwiftUI

class UserViewModel: ObservableObject, LoadingViewModel {
    
    // 사용자 정보
    @Published var user: User?
    @Published var token: String? = nil
    
    // 오류 메시지
    @Published var errorMessage: String?
    
    // 로딩 상태 표시
    @Published var isLoading: Bool = false
    @Published var loadingMessage: String? = nil
    
    @Published var showAlert: Bool = false

    private var userService = UserService()
    
    static let shared = UserViewModel()

    // 프로필 정보 가져오기
    func getProfile(userId: String?) {
        
        isLoading = true
        loadingMessage = "사용자 정보 불러오는 중..."
        
        userService.getProfile(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.loadingMessage = nil
                switch result {
                case .success(let user):
                    self?.user = user
                case .failure(let error):
                    if let nsError = error as NSError?, nsError.code == -3 { // -3은 토큰 갱신 실패
                        DispatchQueue.main.async {
                            self?.showAlert = true
                        }
                    }
                    self?.errorMessage = error.localizedDescription
                    print("get profile Error Detail: \(error)")
                }
            }
        }
    }
    
    // MARK: - USER STORY COUNT
    private var storyService = BookStoryService()
    @Published var storyCount: Int?
    
    func loadStoryCount(userId: String?) {
        isLoading = true
        loadingMessage = "로딩 중..."
        
        storyService.getUserBookStoryCount(userId: userId) { [weak self] result in
            
            switch result {
            case .success(let storyCountResponse):
                self?.isLoading = false
                self?.loadingMessage = nil

                if storyCountResponse.success {
                    DispatchQueue.main.async {
                        self?.storyCount = storyCountResponse.count
                    }
                } else {
                    self?.errorMessage = "Failed to fetch story count."
                }
            case .failure(let error):
                self?.isLoading = false
                self?.loadingMessage = nil

                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    
    // 프로필 수정
    func updateProfile(nickname: String, profileImage: UIImage?, statusMessage: String, monthlyReadingGoal: Int, completion: @escaping (Result<User, Error>) -> Void) {
        isLoading = true
        loadingMessage = "프로필 수정 중..."
        
        userService.updateProfile(nickname: nickname, profileImage: profileImage, statusMessage: statusMessage, monthlyReadingGoal: monthlyReadingGoal) { [weak self] result in
            DispatchQueue.main.async {
                
                switch result {
                case .success(let user):
                    self?.isLoading = false
                    self?.loadingMessage = nil

                    self?.user = user
                    completion(.success(user))
                case .failure(let error as NSError):
                    self?.isLoading = false
                    self?.loadingMessage = nil

                    // 백엔드에서 오는 오류 메시지 사용
                    self?.errorMessage = error.localizedDescription
                    print("Error Detail: \(error)")
                    completion(.failure(error))
                case .failure(let error):
                    // 다른 종류의 오류 처리
                    self?.errorMessage = error.localizedDescription
                    print("Error Detail: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
}
