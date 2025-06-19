//
//  BlockReportService.swift
//  QuoteHub
//
//  Created by 이융의 on 6/20/25.
//

import Foundation

protocol BlockReportServiceProtocol {
    /// 사용자 차단
    func blockUser(
        targetUserId: String
    ) async throws -> APIResponse<EmptyData>
    
    /// 사용자 차단 해제
    func unblockUser(
        targetUserId: String
    ) async throws -> APIResponse<EmptyData>
    
    /// 신고 및 차단 (통합)
    func reportAndBlock(
        targetId: String,
        type: Report.ReportType,
        reason: String?
    ) async throws -> APIResponse<EmptyData>
    
    /// 신고 취소
    func cancelReport(
        targetId: String,
        type: Report.ReportType
    ) async throws -> APIResponse<EmptyData>
    
    /// 차단 목록 조회
    func getBlockedUsers() async throws -> APIResponse<[User]>
    
    /// 신고 목록 조회
    func getReports() async throws -> APIResponse<[Report]>
}

final class BlockReportService: BlockReportServiceProtocol {
    
    // MARK: - Properties
    static let shared = BlockReportService()
    
    private let apiClient: APIClient
    
    // MARK: - Initialization
    private init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    /// 사용자 차단
    func blockUser(
        targetUserId: String
    ) async throws -> APIResponse<EmptyData> {
        
        // 입력 값 검증
        guard !targetUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.serverError(400, "차단할 사용자 ID가 필요합니다.")
        }
        
        let requestBody = ["targetUserId": targetUserId]
        
        return try await apiClient.request(
            endpoint: BlockReportEndpoints.blockUser,
            body: .dictionary(requestBody),
            responseType: APIResponse<EmptyData>.self
        )
    }
    
    /// 사용자 차단 해제
    func unblockUser(
        targetUserId: String
    ) async throws -> APIResponse<EmptyData> {
        
        // 입력 값 검증
        guard !targetUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.serverError(400, "차단 해제할 사용자 ID가 필요합니다.")
        }
        
        let requestBody = ["targetUserId": targetUserId]
        
        return try await apiClient.request(
            endpoint: BlockReportEndpoints.unblockUser,
            body: .dictionary(requestBody),
            responseType: APIResponse<EmptyData>.self
        )
    }
    
    /// 신고 및 차단 (통합)
    func reportAndBlock(
        targetId: String,
        type: Report.ReportType,
        reason: String? = nil
    ) async throws -> APIResponse<EmptyData> {
        
        // 입력 값 검증
        guard !targetId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.serverError(400, "신고할 대상 ID가 필요합니다.")
        }
        
        var requestBody: [String: Any] = [
            "targetId": targetId,
            "type": type.rawValue
        ]
        
        // reason이 있으면 추가, 없으면 서버에서 기본값 사용
        if let reason = reason, !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            requestBody["reason"] = reason
        }
        
        return try await apiClient.request(
            endpoint: BlockReportEndpoints.reportAndBlock,
            body: .dictionary(requestBody),
            responseType: APIResponse<EmptyData>.self
        )
    }
    
    /// 신고 취소
    func cancelReport(
        targetId: String,
        type: Report.ReportType
    ) async throws -> APIResponse<EmptyData> {
        
        // 입력 값 검증
        guard !targetId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.serverError(400, "신고 취소할 대상 ID가 필요합니다.")
        }
        
        let requestBody: [String: Any] = [
            "targetId": targetId,
            "type": type.rawValue
        ]
        
        return try await apiClient.request(
            endpoint: BlockReportEndpoints.cancelReport,
            body: .dictionary(requestBody),
            responseType: APIResponse<EmptyData>.self
        )
    }
    
    /// 차단 목록 조회
    func getBlockedUsers() async throws -> APIResponse<[User]> {
        return try await apiClient.request(
            endpoint: BlockReportEndpoints.getBlockedUsers,
            body: .empty,
            responseType: APIResponse<[User]>.self
        )
    }
    
    /// 신고 목록 조회
    func getReports() async throws -> APIResponse<[Report]> {
        return try await apiClient.request(
            endpoint: BlockReportEndpoints.getReports,
            body: .empty,
            responseType: APIResponse<[Report]>.self
        )
    }
}
