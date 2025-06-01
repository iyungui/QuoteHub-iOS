//
//  HomeView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import SDWebImageSwiftUI

/// 첫번째 탭 뷰
struct HomeView: View {
    @StateObject var booksViewModel = RandomBooksViewModel()
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            backgroundColor
            
            ScrollView {
                VStack(spacing: 0) {
                    /// hero 섹션
                    heroSection
                    
                    spacer(height: 40)
                    
                    /// 북스토리 모아보기 섹션 (최신순)
                    VStack(spacing: 20) {
                        sectionHeader(
                            title: "북스토리 모아보기",
                            gradient: [.brownLeather, .antiqueGold]
                        )
                        // TODO: - 로딩 중 상태 표시
                        PublicStoriesListView()
                            .environmentObject(storiesViewModel)
                            .environmentObject(userAuthManager)
                            .environmentObject(userViewModel)
                            .frame(height: 350)
                    }
                    
                    spacer(height: 60)
                    
                    /// 테마별 모아보기 섹션
                    VStack(spacing: 20) {
                        sectionHeader(
                            title: "테마별 모아보기",
                            gradient: [.antiqueGold, .brownLeather]
                        )
                        
                        // TODO: - 로딩 중 상태 표시
                        ThemeListView()
                            .environmentObject(userAuthManager)
                            .environmentObject(userViewModel)
                            .environmentObject(themesViewModel)
                            .environmentObject(storiesViewModel)
                            .frame(height: 220)
                    }

                    spacer(height: 60)
                    
                    /// 지금 뜨고 있는 책 섹션
                    VStack(spacing: 20) {
                        sectionHeader(
                            title: "지금 뜨고 있는 책",
                            gradient: [Color.orange.opacity(0.8), Color.red.opacity(0.7)]
                        )
                        
                        if booksViewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.brownLeather)
                        } else {
                            RandomBookListView()
                                .frame(height: 320)
                        }
                    }
                    
                    spacer(height: 100) // 여유 공간
                }
                .padding(.top, 20)
            }
            .refreshable {
                await refreshContent()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                navBarLogo()
            }
            ToolbarItem(placement: .topBarTrailing) {
                navBarActions()
            }
        }
    }
    
    // MARK: - Private Methods
    // TODO: - 비동기적으로 처리
    private func refreshContent() async {
        booksViewModel.getRandomBooks()
        storiesViewModel.refreshBookStories(type: .public)
        themesViewModel.refreshThemes(type: .public)
    }
    
    // MARK: - UI Components

    private var backgroundColor: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.softBeige.opacity(0.3),
                Color.lightPaper.opacity(0.3),
                Color.paperBeige.opacity(0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var heroSection: some View {
        VStack(spacing: 12) {
            Text("오늘도 좋은 문장과 함께")
                .font(.scoreDream(.bold, size: .title2))
                .foregroundStyle(Color.brown)

            Text("마음에 드는 구절들을 깊이 간직해보세요")
                .font(.scoreDream(.regular, size: .subheadline))
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.heroBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.paperBeige.opacity(0.5), .antiqueGold.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .adaptiveShadow()
        )
        .padding(.horizontal, 20)
    }
    
    private func sectionHeader(title: String, gradient: [Color]) -> some View {
        HStack(spacing: 15) {
            // 제목
            Text(title)
                .font(.scoreDream(.bold, size: .title2))
                .foregroundColor(.primaryText)
            
            Spacer()
            
            // 그라데이션 라인
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: gradient + [Color.clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: 100)
        }
        .padding(.horizontal, 30)
    }
    
    public func navBarActions() -> some View {
        HStack(spacing: 15) {
            // 테마 토글 버튼
            ThemeToggleButton()
            
            if userAuthManager.isUserAuthenticated {
                NavigationLink(destination: UserSearchView()
                    .environmentObject(storiesViewModel)
                    .environmentObject(userAuthManager)
                ) {
                    Image(systemName: "person.2")
                        .foregroundColor(.brownLeather)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            
            NavigationLink(destination: SearchStoryByKeywordView(type: .public)
                .environmentObject(userViewModel)
//                .environmentObject(storiesViewModel)
                .environmentObject(userAuthManager)
            ) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.brownLeather)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
}

