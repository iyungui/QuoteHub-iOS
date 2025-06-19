//
//  ThemeService.swift
//  QuoteHub
//
//  Created by 이융의 on 6/19/25.
//

import SwiftUI

protocol ThemeServiceProtocol {
    /// 테마 생성
    func createTheme(
        image: UIImage?,
        name: String,
        description: String?,
        isPublic: Bool
    ) async throws -> APIResponse<Theme>
    
    /// 테마 수정
    func updateTheme(
        themeId: String,
        image: UIImage?,
        name: String,
        description: String?,
        isPublic: Bool
    ) async throws -> APIResponse<Theme>
    
    /// 테마 삭제
    func deleteTheme(
        themeId: String
    ) async throws -> APIResponse<EmptyData>
    
    /// 모든 공개 테마 조회
    func getAllThemes(
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<Theme>
    
    /// 특정 사용자 테마 조회
    func getUserThemes(
        userId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<Theme>
    
    /// 내 테마 조회
    func getMyThemes(
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<Theme>
}

final class ThemeService: ThemeServiceProtocol {
    
    // MARK: - Properties
    static let shared = ThemeService()
    
    private let apiClient: APIClient
    
    // MARK: - Initialization
    private init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    /// 테마 생성
    func createTheme(
        image: UIImage? = nil,
        name: String,
        description: String? = nil,
        isPublic: Bool
    ) async throws -> APIResponse<Theme> {
        
        // 이름 유효성 검증
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.serverError(400, "테마 이름은 비어있을 수 없습니다.")
        }
        
        // 공통 필드 구성
        var fields: [String: Any] = [
            "name": name,
            "isPublic": isPublic
        ]
        
        if let description = description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fields["description"] = description
        } else {
            fields["description"] = ""
        }
        
        // 요청 Body 타입 결정
        let requestBody: RequestBody
        
        if let image = image {
            // 이미지가 있는 경우: Multipart 요청
            requestBody = .multipart(
                textFields: fields,
                singleImages: ["folderImage": image]
            )
        } else {
            // 이미지가 없는 경우: JSON 요청
            requestBody = .dictionary(fields)
        }
        
        return try await apiClient.request(
            endpoint: ThemeEndpoints.createTheme,
            body: requestBody,
            responseType: APIResponse<Theme>.self
        )
    }
    
    /// 테마 수정
    func updateTheme(
        themeId: String,
        image: UIImage? = nil,
        name: String,
        description: String? = nil,
        isPublic: Bool
    ) async throws -> APIResponse<Theme> {
        
        // 이름 유효성 검증
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.serverError(400, "테마 이름은 비어있을 수 없습니다.")
        }
        
        // 공통 필드 구성
        var fields: [String: Any] = [
            "name": name,
            "isPublic": isPublic
        ]
        
        if let description = description {
            fields["description"] = description
        } else {
            fields["description"] = ""
        }
        
        // 요청 Body 타입 결정
        let requestBody: RequestBody
        
        if let image = image {
            // 이미지가 있는 경우: Multipart 요청
            requestBody = .multipart(
                textFields: fields,
                singleImages: ["folderImage": image]
            )
        } else {
            // 이미지가 없는 경우: JSON 요청
            requestBody = .dictionary(fields)
        }
        
        return try await apiClient.request(
            endpoint: ThemeEndpoints.updateTheme(themeId: themeId),
            body: requestBody,
            responseType: APIResponse<Theme>.self
        )
    }
    
    /// 테마 삭제
    func deleteTheme(
        themeId: String
    ) async throws -> APIResponse<EmptyData> {
        return try await apiClient.request(
            endpoint: ThemeEndpoints.deleteTheme(themeId: themeId),
            body: .empty,
            responseType: APIResponse<EmptyData>.self
        )
    }
    
    /// 모든 공개 테마 조회
    func getAllThemes(
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<Theme> {
        return try await apiClient.request(
            endpoint: ThemeEndpoints.getAllThemes(page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<Theme>.self
        )
    }
    
    /// 특정 사용자 테마 조회
    func getUserThemes(
        userId: String,
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<Theme> {
        return try await apiClient.request(
            endpoint: ThemeEndpoints.getUserThemes(userId: userId, page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<Theme>.self
        )
    }
    
    /// 내 테마 조회
    func getMyThemes(
        page: Int,
        pageSize: Int
    ) async throws -> PaginatedAPIResponse<Theme> {
        return try await apiClient.request(
            endpoint: ThemeEndpoints.getMyThemes(page: page, pageSize: pageSize),
            body: .empty,
            responseType: PaginatedAPIResponse<Theme>.self
        )
    }
}
