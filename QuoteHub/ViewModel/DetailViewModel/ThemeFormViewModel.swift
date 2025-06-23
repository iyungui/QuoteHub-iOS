//
//  ThemeFormViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/23/25.
//

import SwiftUI

@MainActor
@Observable
class ThemeFormViewModel {
    // Alert Properties
    var showAlert: Bool = false
    var alertMessage: String = ""
    var alertType: PhotoPickerAlertType = .authorized
    var feedbackMessage: String? = nil
    
    // Form Input Properties
    var title: String = ""
    var content: String = ""
    var inputImage: UIImage?
    var isPublic: Bool = true
    
    // Image Picker Properties
    var showingImagePicker = false
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // Constants
    private let titleMaxLength = 20
    private let contentMaxLength = 100
    
    // Computed Properties
    
    /// 폼 유효성 검사
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 모든 입력이 비어있는지 확인
    var isEmpty: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        inputImage == nil
    }
    
    // MARK: - Validation Methods
    
    /// 제목 글자수 제한 검사 및 적용
    func validateTitleLength(_ newValue: String) {
        if newValue.count > titleMaxLength {
            title = String(newValue.prefix(titleMaxLength))
        } else {
            title = newValue
        }
    }
    
    /// 내용 글자수 제한 검사 및 적용
    func validateContentLength(_ newValue: String) {
        if newValue.count > contentMaxLength {
            content = String(newValue.prefix(contentMaxLength))
        } else {
            content = newValue
        }
    }
    
    /// 제목 글자수 반환
    var titleCount: Int {
        title.count
    }
    
    /// 내용 글자수 반환
    var contentCount: Int {
        content.count
    }
    
    /// 제목 최대 글자수 반환
    var titleMaxCount: Int {
        titleMaxLength
    }
    
    /// 내용 최대 글자수 반환
    var contentMaxCount: Int {
        contentMaxLength
    }
    
    // MARK: - Image Methods
    
    /// 이미지 선택 시작
    func selectImage() {
        PermissionsManager.shared.checkPhotosAuthorization { [weak self] authorized in
            guard let self = self else { return }
            
            if authorized {
                self.showingImagePicker = true
            } else {
                self.showPermissionAlert()
            }
        }
    }
    
    /// 권한 거부 시 알림 표시
    private func showPermissionAlert() {
        alertType = .authorized
        alertMessage = "테마에 이미지를 업로드하려면 사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
        showAlert = true
    }
    
    /// 이미지 제거
    func removeImage() {
        inputImage = nil
    }
    
    // MARK: - Feedback Methods
    
    /// 피드백 메시지 업데이트
    func updateFeedbackMessage() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                feedbackMessage = "테마 제목을 입력해주세요."
            } else {
                feedbackMessage = nil
            }
        }
    }
    
    /// 피드백 메시지 초기화
    func clearFeedbackMessage() {
        withAnimation {
            feedbackMessage = nil
        }
    }
    
    // MARK: - Form Management
    
    /// 폼 초기화
    func resetForm() {
        title = ""
        content = ""
        inputImage = nil
        isPublic = true
        feedbackMessage = nil
        showAlert = false
        alertMessage = ""
    }
    
    /// 테마 데이터로부터 폼 로드 (수정 모드용)
    func loadFromTheme(_ theme: Theme) {
        title = theme.name
        content = theme.description ?? ""
        isPublic = theme.isPublic
        
        // 이미지 로드
        loadImageFromTheme(theme)
    }
    
    /// 테마 이미지 비동기 로드
    private func loadImageFromTheme(_ theme: Theme) {
        guard let imageUrlString = theme.themeImageURL,
              let url = URL(string: imageUrlString) else {
            inputImage = nil
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.inputImage = image
                    }
                }
            } catch {
                print("테마 이미지 로드 실패: \(error.localizedDescription)")
                await MainActor.run {
                    self.inputImage = nil
                }
            }
        }
    }
    
    // MARK: - Theme Submission
    
    /// 테마 제출 데이터 검증
    func validateForSubmission() -> Bool {
        guard isFormValid else {
            updateFeedbackMessage()
            return false
        }
        return true
    }
    
    /// 제출용 테마 데이터 준비
    func prepareThemeData() -> (image: UIImage?, name: String, description: String?, isPublic: Bool) {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalContent = trimmedContent.isEmpty ? nil : trimmedContent
        
        return (
            image: inputImage,
            name: title,
            description: finalContent,
            isPublic: isPublic
        )
    }
    
    /// 성공 알림 표시
    func showSuccessAlert() {
        alertType = .make
        alertMessage = "테마가 성공적으로 등록되었어요!"
        showAlert = true
    }
    
    /// 에러 알림 표시
    func showErrorAlert(_ message: String? = nil) {
        alertType = .make
        alertMessage = message ?? "테마 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        showAlert = true
    }
    
    /// 테마 로드 실패 알림 표시
    func showLoadErrorAlert(_ message: String? = nil) {
        alertType = .make
        alertMessage = message ?? "테마를 불러오지 못했어요."
        showAlert = true
    }
}
