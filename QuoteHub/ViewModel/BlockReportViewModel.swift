//
//  BlockReportViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/20/25.
//

import Foundation

@MainActor
@Observable
final class BlockReportViewModel: LoadingViewModel {
    
    // MARK: - LoadingViewModel 프로토콜 구현
    var isLoading = false
    var loadingMessage: String?
    
    // MARK: - Published Properties
    var errorMessage: String?
    var successMessage: String?
    
    // MARK: - Private Properties
    private let service: BlockReportServiceProtocol
    
    // MARK: - Initialization
    init(service: BlockReportServiceProtocol = BlockReportService.shared) {
        self.service = service
    }
    
    // MARK: - Public Methods
    
    /// 사용자 차단
    func blockUser(_ targetUserId: String) async -> Bool {
        isLoading = true
        loadingMessage = "사용자를 차단하는 중..."
        clearMessages()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.blockUser(targetUserId: targetUserId)
            
            if response.success {
                successMessage = "사용자를 차단했습니다."
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
    
    /// 사용자 차단 해제
    func unblockUser(_ targetUserId: String) async -> Bool {
        isLoading = true
        loadingMessage = "차단을 해제하는 중..."
        clearMessages()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.unblockUser(targetUserId: targetUserId)
            
            if response.success {
                successMessage = "차단을 해제했습니다."
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
    
    /// 신고 및 차단
    func reportAndBlock(
        targetId: String,
        type: Report.ReportType,
        reason: String? = nil
    ) async -> Bool {
        isLoading = true
        loadingMessage = "신고하는 중..."
        clearMessages()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.reportAndBlock(
                targetId: targetId,
                type: type,
                reason: reason
            )
            
            if response.success {
                successMessage = "신고가 접수되었습니다."
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
    
    /// 신고 취소
    func cancelReport(
        targetId: String,
        type: Report.ReportType
    ) async -> Bool {
        isLoading = true
        loadingMessage = "신고를 취소하는 중..."
        clearMessages()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.cancelReport(
                targetId: targetId,
                type: type
            )
            
            if response.success {
                successMessage = "신고를 취소했습니다."
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
    
    /// 차단 목록 조회
    func getBlockedUsers() async -> [User] {
        isLoading = true
        loadingMessage = "차단 목록을 불러오는 중..."
        clearMessages()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.getBlockedUsers()
            
            if response.success {
                return response.data ?? []
            } else {
                errorMessage = response.message
                return []
            }
        } catch {
            handleError(error)
            return []
        }
    }
    
    /// 신고 목록 조회
    func getReports() async -> [Report] {
        isLoading = true
        loadingMessage = "신고 목록을 불러오는 중..."
        clearMessages()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.getReports()
            
            if response.success {
                return response.data ?? []
            } else {
                errorMessage = response.message
                return []
            }
        } catch {
            handleError(error)
            return []
        }
    }
}

// MARK: - Private Helper Methods
private extension BlockReportViewModel {
    
    /// 메시지 초기화
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    /// 에러 처리
    func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
}
