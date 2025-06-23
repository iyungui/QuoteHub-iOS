//
//  LibraryBaseView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

/// 라이브러리 뷰의 공통 레이아웃을 제공하는 베이스 뷰
struct LibraryBaseView<ProfileContent: View, ContentSectionContent: View, NavigationItems: View>: View {
    
    // MARK: - Properties
    @Binding var selectedTab: LibraryTab
    let showKeywords: Bool // 키워드 탭 표시 여부 추가
    
    let profileSection: () -> ProfileContent
    let contentSection: () -> ContentSectionContent
    let navigationBarItems: () -> NavigationItems
    
    // MARK: - State
    @State private var stickyTabVisible = false
    @State private var originalTabPosition: CGFloat = 0
    
    // MARK: - Computed Properties
    private var availableTabs: [LibraryTab] {
        LibraryTab.availableTabs(showKeywords: showKeywords)
    }
    
    // MARK: - BODY
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            VStack(spacing: 20) {
                                // 프로필 섹션
                                profileSection()
                                
                                // 탭 섹션 (원본)
                                LibraryTabSection(
                                    selectedTab: $selectedTab,
                                    showKeywords: showKeywords
                                )
                                .id("tabSection")
                                .background(
                                    GeometryReader { tabGeometry in
                                        Color.clear
                                            .onAppear {
                                                originalTabPosition = tabGeometry.frame(in: .global).minY
                                            }
                                            .onChange(of: tabGeometry.frame(in: .global).minY) { _, newY in
                                                updateStickyState(currentY: newY)
                                            }
                                    }
                                )
                                .opacity(stickyTabVisible ? 0 : 1)
                                
                                // 콘텐츠 섹션
                                contentSection()
                                
                                Spacer().frame(height: 100)
                            }
                            .padding(.top, 10)
                        }
                        .onChange(of: selectedTab) { _, newTab in
                            // 선택된 탭이 사용 가능한 탭이 아니라면 첫 번째 탭으로 변경
                            if !availableTabs.contains(newTab) {
                                selectedTab = availableTabs.first ?? .stories
                            }
                            
                            withAnimation(.easeInOut(duration: 0.1)) {
                                proxy.scrollTo("tabSection", anchor: .top)
                            }
                        }
                    }
                    .scrollIndicators(.automatic)
                }
                
                // Sticky 탭 (조건부로만 표시)
                if stickyTabVisible {
                    LibraryTabSection(
                        selectedTab: $selectedTab,
                        showKeywords: showKeywords
                    )
                    .background(Color(.systemGroupedBackground))
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
                    .zIndex(999)
                }
            }
        }
        .backgroundGradient()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                navigationBarItems()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 뷰가 나타날 때 선택된 탭이 유효한지 확인
            if !availableTabs.contains(selectedTab) {
                selectedTab = availableTabs.first ?? .stories
            }
        }
    }
    
    private func updateStickyState(currentY: CGFloat) {
        let safeAreaTop = getSafeAreaTop()
        let shouldShowSticky = currentY <= safeAreaTop + 44
        
        if shouldShowSticky != stickyTabVisible {
            withAnimation(.none) {
                stickyTabVisible = shouldShowSticky
            }
        }
    }
    
    private func getSafeAreaTop() -> CGFloat {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }
}
