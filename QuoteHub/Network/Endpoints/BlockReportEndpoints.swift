//
//  BlockReportEndpoints.swift
//  QuoteHub
//
//  Created by 이융의 on 6/20/25.
//

import Foundation

enum BlockReportEndpoints: EndpointProtocol {
    // 차단 관련
    case blockUser
    case unblockUser
    
    // 신고 관련
    case reportAndBlock
    case cancelReport
    
    // 목록 조회
    case getBlockedUsers
    case getReports
    
    var path: String {
        switch self {
        case .blockUser:
            return "/block-report/block"
        case .unblockUser:
            return "/block-report/unblock"
        case .reportAndBlock:
            return "/block-report/report"
        case .cancelReport:
            return "/block-report/cancel-report"
        case .getBlockedUsers:
            return "/block-report/blocked-users"
        case .getReports:
            return "/block-report/reports"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .blockUser, .unblockUser, .reportAndBlock, .cancelReport:
            return .POST
        case .getBlockedUsers, .getReports:
            return .GET
        }
    }
    
    var requiresAuth: Bool {
        // 모든 차단/신고 기능은 인증 필요
        return true
    }
}
