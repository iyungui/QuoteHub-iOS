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
    
    let profileSection: () -> ProfileContent
    let contentSection: () -> ContentSectionContent
    let navigationBarItems: () -> NavigationItems
    
    // MARK: - State
    @State private var stickyTabVisible = false
    @State private var originalTabPosition: CGFloat = 0
    
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
                                    selectedTab: $selectedTab
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
                    }
                    .scrollIndicators(.automatic)
                }
                
                // Sticky 탭 (조건부로만 표시)
                if stickyTabVisible {
                    LibraryTabSection(
                        selectedTab: $selectedTab
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
