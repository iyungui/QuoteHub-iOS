//
//  FolderViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 11/10/23.
//

import Foundation
import SwiftUI

class FolderViewModel: ObservableObject {
    @Published var folder = [Folder]()
    @Published var isLoading = false
    @Published var isLastPage = false

    private var currentPage = 1
    private let pageSize = 10
    private var service = FolderService()

    init() {
        loadFolders()
    }
    
    func refreshFolders() {
        currentPage = 1
        isLastPage = false
        isLoading = false
        folder.removeAll()
        loadFolders()
    }
    
    func loadFolders() {
        guard !isLoading && !isLastPage else { return }
        
        isLoading = true
        
        service.getAllFolders(page: currentPage, pageSize: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.folder.append(contentsOf: response.data)
                    self?.isLastPage = response.pagination.currentPage >= response.pagination.totalPages

                    self?.currentPage += 1
                    self?.isLoading = false
                case .failure(let error):
                    print("Error loading Folder List: \(error)")
                }
            }
        }
    }
    
    func loadMoreIfNeeded(currentItem item: Folder?) {
        guard let item = item else { return }

        if item == folder.last {
            loadFolders()
        }
    }
}

// MARK: - MY

class MyFolderViewModel: ObservableObject {
    @Published var folder = [Folder]()
    @Published var isLoading = false
    @Published var isLastPage = false

    private var currentPage = 1
    private let pageSize = 10
    private var service = FolderService()
    @Published var errorMessage: String?
    
    init() {
        loadFolders()
    }
    
    func refreshFolders() {
        currentPage = 1
        isLastPage = false
        isLoading = false
        folder.removeAll()
        loadFolders()
    }
    
    func loadFolders() {
        guard !isLoading && !isLastPage else { return }
    
        isLoading = true
        
        service.getMyFolders(page: currentPage, pageSize: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.folder.append(contentsOf: response.data)
                    self?.isLastPage = response.pagination.currentPage >= response.pagination.totalPages

                    self?.currentPage += 1
                    self?.isLoading = false
                case .failure(let error):
                    print("Error loading Folder List: \(error)")
                }
            }
        }
    }
    
    func loadMoreIfNeeded(currentItem item: Folder?) {
        guard let item = item else { return }

        if item == folder.last {
            loadFolders()
        }
    }
    
    // MARK: - CREATE NEW FOLDER
    
    func createFolder(image: UIImage?, name: String, description: String?, isPublic: Bool, completion: @escaping (Bool) -> Void) {
        isLoading = true

        service.createFolder(image: image, name: name, description: description, isPublic: isPublic) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let folderResponse):
                    // 새 폴더를 folders 배열에 추가
                    self?.folder.insert(folderResponse.data!, at: 0)
                    self?.isLoading = false
                    completion(true)
                case .failure(let error as NSError):
                    self?.isLoading = false
                    if error.code == 409 {
                        self?.errorMessage = "중복된 폴더 이름이 있습니다."
                        completion(false)
                    } else {
                        self?.errorMessage = nil
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - UPDATE MY FOLDER
    
    func folder(with id: String) -> Folder? {
        return folder.first { $0.id == id }
    }
    
    func updateFolder(folderId: String, image: UIImage?, name: String, description: String?, isPublic: Bool, completion: @escaping (Bool) -> Void) {
        isLoading = true

        service.updateFolder(folderId: folderId, image: image, name: name, description: description, isPublic: isPublic) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedFolderResponse):
                    if let index = self?.folder.firstIndex(where: { $0.id == folderId}) {
                        self?.folder[index] = updatedFolderResponse.data!
                    }
                    self?.isLoading = false
                    completion(true)
                case .failure(let error as NSError):
                    self?.isLoading = false
                    if error.code == 409 {
                        self?.errorMessage = "중복된 폴더 이름이 있습니다."
                        completion(false)
                    } else {
                        self?.errorMessage = "Error updating Folder: \(error.localizedDescription)"
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - DELETE MY FOLDER
    
    func deleteFolder(folderId: String, completion: @escaping (Bool) -> Void) {
        service.deleteFolder(folderId: folderId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if let index = self?.folder.firstIndex(where: { $0.id == folderId}) {
                        self?.folder.remove(at: index)
                    }
                    completion(true)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(false)
                }
            }
        }
    }
}

// MARK: - FRIEND

class FriendFolderViewModel: ObservableObject {
    @Published var folder = [Folder]()
    @Published var isLoading = false
    @Published var isLastPage = false

    private var currentPage = 1
    private let pageSize = 10
    private var service = FolderService()

    private var userId: String
    
    init(userId: String) {
        self.userId = userId
        loadFolders()
        
    }
    
    func refreshFolders() {
        currentPage = 1
        isLastPage = false
        isLoading = false
        folder.removeAll()
        loadFolders()
    }
    
    func loadFolders() {
        guard !isLoading && !isLastPage else { return }
        
        isLoading = true
        
        service.getUserFolders(userId: userId, page: currentPage, pageSize: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.folder.append(contentsOf: response.data)
                    self?.isLastPage = response.pagination.currentPage >= response.pagination.totalPages

                    self?.currentPage += 1
                    self?.isLoading = false
                case .failure(let error):
                    print("Error loading Folder List: \(error)")
                }
            }
        }
    }
    
    func loadMoreIfNeeded(currentItem item: Folder?) {
        guard let item = item else { return }

        if item == folder.last {
            loadFolders()
        }
    }
}
