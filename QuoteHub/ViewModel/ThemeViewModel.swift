//
//  ThemeViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 11/10/23.
//

import Foundation
import SwiftUI

class ThemesViewModel: ObservableObject {
    
    @Published var themes = [Theme]()
//    @Published var myThemes = [Folder]()
    
    @Published var isLoading = false
    @Published var isLastPage = false
    @Published var errorMessage: String?
    
    private var currentPage = 1
    private let pageSize = 10
    private var service = FolderService()
    
    private var currentThemeType: LoadType = .my

//    init() {
//        loadFolders()
//    }
    
    func refreshThemes(type: LoadType) {
        currentPage = 1
        isLastPage = false
        isLoading = false
        themes.removeAll()
        loadThemes(type: type)
    }
    
    // TODO: - 사용하지 않는 메서드 제거
    
    func theme(with id: String) -> Theme? {
        return themes.first { $0.id == id }
    }
    
    // MARK: - LOAD THEMES
    
    func loadThemes(type: LoadType) {
        print(#fileID, #function, #line, "- ")
        
        guard !isLoading && !isLastPage else { return }
        
        isLoading = true
        currentThemeType = type
        
        let completion: (Result<ThemesListResponse, Error>) -> Void = { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                    // 메인스레드에서 비동기 실행
                    
                    // TODO: UI관계없고, 시간이 오래걸리는 작업은 다른 쓰레드로 옮기기
                case .success(let response):
//                    if type == .my {
//                        self.myThemes.append(contentsOf: response.data)
//                    } else {
                        self.themes.append(contentsOf: response.data)
//                    }
                    self.isLastPage = response.pagination.currentPage >= response.pagination.totalPages
                    self.currentPage += 1
                    self.isLoading = false
                case .failure(let error):
                    print("Error loading Themes List: (\(type)): \(error)")
                    self.isLoading = false
                    
                }
            }
        }
        
        switch type {
        case .my:   // my로 조회 시, (비공개 테마까지 조회)
            service.getMyFolders(page: currentPage, pageSize: pageSize, completion: completion)
        case .friend(let friendId):
            service.getUserFolders(userId: friendId, page: currentPage, pageSize: pageSize, completion: completion)
        case .public:
            service.getAllFolders(page: currentPage, pageSize: pageSize, completion: completion)
        }
    }
    
    func loadMoreIfNeeded(currentItem item: Theme?) {
        print(#fileID, #function, #line, "- ")
        
        guard let item = item else { return }
        
        if item == themes.last {
            loadThemes(type: currentThemeType)
        }
    }

    // MARK: - CREATE NEW THEME
    // TODO: - 이미지 옵셔널

    func createTheme(image: UIImage?, name: String, description: String?, isPublic: Bool, completion: @escaping (Bool) -> Void) {
        print(#fileID, #function, #line, "- ")
        
        service.createFolder(image: image, name: name, description: description, isPublic: isPublic) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = true
            
            DispatchQueue.main.async {
                switch result {
                case .success(let themeResponse):
                    // 새 폴더를 themes 배열에 추가
                    self.themes.insert(themeResponse.data!, at: 0)
                    self.isLoading = false
                    
                    print("테마 생성 완료")
                    completion(true)
                    
                case .failure(let error as NSError):
                    self.isLoading = false
                    
                    print("테마 생성 실패: \(error.localizedDescription)")
                    if error.code == 409 {
                        self.errorMessage = "중복된 폴더 이름이 있습니다."
                        completion(false)
                    } else {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - UPDATE MY FOLDER
    
    func updateTheme(folderId: String, image: UIImage?, name: String, description: String?, isPublic: Bool, completion: @escaping (Bool) -> Void) {
        print(#fileID, #function, #line, "- ")
        
        service.updateFolder(folderId: folderId, image: image, name: name, description: description, isPublic: isPublic) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = true
            
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedFolderResponse):
                    if let index = self.themes.firstIndex(where: { $0.id == folderId}) {
                        self.themes[index] = updatedFolderResponse.data!
                    }
                    
                    self.isLoading = false
                    
                    print("테마 업데이트 완료")
                    completion(true)
                    
                case .failure(let error as NSError):
                    self.isLoading = false
                    
                    print("테마 업데이트 실패: \(error.localizedDescription)")
                    
                    if error.code == 409 {
                        self.errorMessage = "중복된 테마 이름이 있습니다."
                        completion(false)
                    } else {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - DELETE MY FOLDER
    
    func deleteFolder(folderId: String, completion: @escaping (Bool) -> Void) {
        print(#fileID, #function, #line, "- ")
        
        service.deleteFolder(folderId: folderId) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = true
            
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.isLoading = false
                    
                    if let index = self.themes.firstIndex(where: { $0.id == folderId}) {
                        self.themes.remove(at: index)
                    }
                    print("테마 삭제 완료")
                    completion(true)
                    
                case .failure(let error):
                    self.isLoading = false
                    
                    print("테마 삭제 실패 - \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
}
