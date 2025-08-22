//
//  ThemesViewModelProtocols.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

// MARK: - 기본 읽기 전용 프로토콜
@MainActor
protocol ThemesViewModelProtocol: LoadingViewModelProtocol {
    
    // MARK: - Published Properties
    var themes: [Theme] { get }
    var isLastPage: Bool { get }
    var errorMessage: String? { get }
    
    // MARK: - Core Methods
    
    /// 테마 목록 로드 (첫 페이지)
    func loadThemes() async
    
    /// 테마 목록 새로고침 (데이터 초기화 후 재로드)
    func refreshThemes() async
    
    /// 무한 스크롤을 위한 추가 로드
    /// - Parameter currentItem: 현재 표시 중인 아이템
    func loadMoreIfNeeded(currentItem: Theme?) async
    
    /// 특정 테마 상세 조회
    /// - Parameter themeId: 조회할 테마 ID
    /// - Returns: 조회된 테마 (실패시 nil)
    func fetchSpecificTheme(themeId: String) async -> Theme?

}

// MARK: - CRUD 확장 프로토콜 (My 뷰모델만)
@MainActor
protocol EditableThemesViewModelProtocol: ThemesViewModelProtocol {
    
    // MARK: - Create
    
    /// 새 테마 생성
    /// - Parameters:
    ///   - image: 테마 이미지
    ///   - name: 테마 이름
    ///   - description: 테마 설명
    ///   - isPublic: 공개 여부
    /// - Returns: 생성된 테마 (실패시 nil)
    func createTheme(
        image: UIImage?,
        name: String,
        description: String?,
        isPublic: Bool
    ) async -> Theme?
    
    // MARK: - Update
    
    /// 기존 테마 수정
    /// - Parameters:
    ///   - themeId: 수정할 테마 ID
    ///   - image: 수정된 테마 이미지
    ///   - name: 수정된 테마 이름
    ///   - description: 수정된 테마 설명
    ///   - isPublic: 수정된 공개 여부
    /// - Returns: 수정된 테마 (실패시 nil)
    func updateTheme(
        themeId: String,
        image: UIImage?,
        name: String,
        description: String?,
        isPublic: Bool
    ) async -> Theme?
    
    // MARK: - Delete
    
    /// 테마 삭제
    /// - Parameter themeId: 삭제할 테마 ID
    /// - Returns: 삭제 성공 여부
    func deleteTheme(themeId: String) async -> Bool
}

// MARK: - 프로토콜 기본 구현 (공통 로직)
extension ThemesViewModelProtocol {
    
    /// 페이지네이션 체크를 위한 헬퍼 메서드
    /// - Parameter item: 현재 아이템
    /// - Returns: 추가 로드가 필요한지 여부
    @MainActor
    func shouldLoadMore(for item: Theme?) -> Bool {
        guard let item = item else { return false }
        guard !isLoading else { return false }
        
        // 현재 아이템이 마지막에서 3번째 이내면 추가 로드
        if let index = themes.firstIndex(where: { $0.id == item.id }) {
            return index >= themes.count - 3
        }
        
        return false
    }
    
    /// 에러 메시지 클리어
    func clearErrorMessage() {
        // 각 뷰모델에서 구현
    }
    
    /// 로딩 상태 초기화
    func resetLoadingState() {
        // 각 뷰모델에서 구현
    }
}

// MARK: - Typealias
typealias ReadOnlyThemesViewModel = ThemesViewModelProtocol
typealias EditableThemesViewModel = EditableThemesViewModelProtocol
