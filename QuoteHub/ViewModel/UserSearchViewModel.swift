//
//  UserSearchViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 11/16/23.
//

import Foundation
import Combine

class UserSearchViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var userService: UserService
    private var cancellables = Set<AnyCancellable>()

    init(userService: UserService = UserService()) {
        self.userService = userService
    }

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
}
