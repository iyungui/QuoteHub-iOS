//
//  ThemeDetailViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/23/25.
//

import SwiftUI

@MainActor
@Observable
final class ThemeDetailViewModel: LoadingViewModel {
    // MARK: - Init && Properties
    
    // LoadingViewModel Protocol
    var isLoading: Bool = false
    var loadingMessage: String? = ""
    
    // Published Properties
    var theme: Theme? {
        didSet {
            print("Theme: \(theme)")
        }
    }
    var errorMessage: String?
    
    // View State
    var selectedView: Int = 0  // 0: grid, 1: list
    var showActionSheet: Bool = false
    var showAlert: Bool = false
    var alertMessage: String = ""
    var isEditing: Bool = false
    
    // Task Management
    private var loadingTask: Task<Void, Never>?
    
    private let service: ThemeServiceProtocol

    init(service: ThemeServiceProtocol = ThemeService.shared) {
        self.service = service
    }

    // MARK: - Public Methods
    
    /// 테마 id를 통해 서버로부터 해당 최신 테마 받아오는 메서드
    func loadThemeDetail(themeId: String) {
        cancelLoadingTask()
        
        loadingTask = Task {
            await performLoadThemeDetail(themeId: themeId)
        }
    }
    
    /// 뷰 전환 (그리드 <-> 리스트)
    func toggleSelectedView(to view: Int) {
        selectedView = view
    }
    
    /// 액션 시트 표시
    func showActionSheetView() {
        showActionSheet = true
    }
    
    /// 수정 시트 표시
    func showEditSheetView() {
        isEditing = true
    }
    
    /// 수정 시트 닫기
    func hideEditSheetView() {
        isEditing = false
    }
    
    /// 알림 표시
    func showAlertWith(message: String) {
        alertMessage = message
        showAlert = true
    }
}

private extension ThemeDetailViewModel {
    
    /// theme detail view load execution
    func performLoadThemeDetail(themeId: String) async {
        isLoading = true
        loadingMessage = "테마를 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            // Task 취소 확인
            try Task.checkCancellation()
            
            let response = try await service.fetchSpecificTheme(themeId: themeId)
            
            if response.success {
                theme = response.data
            } else {
                errorMessage = "테마를 찾을 수 없습니다."
                showAlertWith(message: "테마를 불러오지 못했어요.")
                return
            }
            
        } catch is CancellationError {
            // Task가 취소된 경우 - 아무것도 하지 않고 리턴
            return
        } catch {
            print("테마 로드 실패: \(error)")
            handleError(error)
            showAlertWith(message: "테마를 불러오지 못했어요.")
        }
    }
    
    /// 로딩 Task 취소
    func cancelLoadingTask() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    /// 에러 메시지 초기화
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    /// 에러 처리
    func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다.: \(error.localizedDescription)"
        }
    }
}
