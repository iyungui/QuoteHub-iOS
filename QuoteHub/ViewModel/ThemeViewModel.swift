//
//  ThemeViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 11/10/23.
//

import Foundation
import SwiftUI

class ThemesViewModel: ObservableObject, LoadingViewModel {
    
    @Published var themesByType: [LoadType: [Theme]] = [:]
    
    @Published var isLoading = false
    @Published var loadingMessage: String?
    @Published var isLastPage = false
    @Published var errorMessage: String?
    
    private var currentPage = 1
    private let pageSize = 10
    private var service = FolderService()
    
    private var currentThemeType: LoadType = .my

    func themes(for type: LoadType) -> [Theme] {
        return themesByType[type] ?? []
    }
    
    func refreshThemes(type: LoadType) {
        currentThemeType = type
        currentPage = 1
        isLastPage = false
        isLoading = false
        
        // 해당 타입의 데이터만 초기화
        themesByType[type] = []
        loadThemes(type: type)
    }
    
    // MARK: - LOAD THEMES
    
    func loadThemes(type: LoadType) {
        print(#fileID, #function, #line, "- ")
        
        // 타입이 바뀐 경우 상태 초기화
        if currentThemeType != type {
            currentThemeType = type
            currentPage = 1
            isLastPage = false
            isLoading = false
        }
        
        guard !isLoading && !isLastPage else { return }
        
        isLoading = true
        loadingMessage = "테마를 불러오는 중..."
        
        let completion: (Result<ThemesListResponse, Error>) -> Void = { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                    // 메인스레드에서 비동기 실행
                    
                    // TODO: UI관계없고, 시간이 오래걸리는 작업은 다른 쓰레드로 옮기기
                case .success(let response):
                    var existingThemes = self.themesByType[type] ?? []
                    existingThemes.append(contentsOf: response.data)
                    self.themesByType[type] = existingThemes
                    
                    self.isLastPage = response.pagination.currentPage >= response.pagination.totalPages
                    self.currentPage += 1
                    sleep(1)
                    self.isLoading = false
                    self.loadingMessage = nil
                case .failure(let error):
                    print("Error loading Themes List: (\(type)): \(error)")
                    self.isLoading = false
                    self.loadingMessage = nil
                    self.errorMessage = "테마를 불러오는 중 오류가 발생했습니다."
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
    
    func loadMoreIfNeeded(currentItem item: Theme?, type: LoadType) {
        print(#fileID, #function, #line, "- ")
        
        guard let item = item else { return }
        let themes = themes(for: type)
        
        if item == themes.last {
            loadThemes(type: type)
        }
    }
    
    // MARK: - HELPER METHODS
    private func addThemeToTypes(_ theme: Theme) {
        // my에 항상 추가
        var myThemes = themesByType[.my] ?? []
        myThemes.insert(theme, at: 0)
        themesByType[.my] = myThemes
        
        // isPublic인 테마는 public에도 바로 추가
        if theme.isPublic {
            var publicThemes = themesByType[.public] ?? []
            publicThemes.insert(theme, at: 0)
            themesByType[.public] = publicThemes
        }
    }
    
    private func removeThemeFromTypes(themeID: String) {
        for (type, themes) in themesByType {
            var updatedThemes = themes
            updatedThemes.removeAll { $0.id == themeID }
            themesByType[type] = updatedThemes
        }
    }
    
    private func updateThemeInTypes(_ theme: Theme) {
        removeThemeFromTypes(themeID: theme.id)
        addThemeToTypes(theme)
    }

    // MARK: - CREATE NEW THEME
    // TODO: - 이미지 옵셔널

    func createTheme(image: UIImage?, name: String, description: String?, isPublic: Bool, completion: @escaping (Bool) -> Void) {
        print(#fileID, #function, #line, "- ")
        
        isLoading = true
        loadingMessage = "테마를 생성하는 중..."
        
        service.createFolder(image: image, name: name, description: description, isPublic: isPublic) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let themeResponse):
                    // 새 폴더를 (my + public) themes에 추가
                    guard let newTheme = themeResponse.data else { return }
                    self.addThemeToTypes(newTheme)
                    
                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    print("테마 생성 완료")
                    completion(true)
                    
                case .failure(let error as NSError):
                    self.isLoading = false
                    self.loadingMessage = nil
                    
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
        
        isLoading = true
        loadingMessage = "테마를 수정하는 중..."
        
        service.updateFolder(folderId: folderId, image: image, name: name, description: description, isPublic: isPublic) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedFolderResponse):
                    guard let updatedTheme = updatedFolderResponse.data else { return }
                    
                    // 관련된 타입들에서 테마 업데이트
                    self.updateThemeInTypes(updatedTheme)

                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    print("테마 업데이트 완료")
                    completion(true)
                    
                case .failure(let error as NSError):
                    self.isLoading = false
                    self.loadingMessage = nil
                    
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
        
        isLoading = true
        loadingMessage = "테마를 삭제하는 중..."
        
        service.deleteFolder(folderId: folderId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.removeThemeFromTypes(themeID: folderId)
                    
                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    print("테마 삭제 완료")
                    completion(true)
                    
                case .failure(let error):
                    self.isLoading = false
                    self.loadingMessage = nil
                    
                    print("테마 삭제 실패 - \(error.localizedDescription)")
                    self.errorMessage = "테마 삭제 중 오류가 발생했습니다."
                    completion(false)
                }
            }
        }
    }
}
