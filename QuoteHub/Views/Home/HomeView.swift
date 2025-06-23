//
//  HomeView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI

/// 첫번째 탭 뷰
struct HomeView: View {
    @State private var booksViewModel = RandomBooksViewModel()
    @Environment(PublicBookStoriesViewModel.self) private var publicBookStoriesViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(PublicThemesViewModel.self) private var publicThemesViewModel

    @Environment(UserAuthenticationManager.self) private var userAuthManager

    var body: some View {
        ScrollView {
            ZStack {
                GradientBackground()

                VStack(spacing: 0) {
                    /// hero 섹션
                    heroSection
                    
                    spacer(height: 40)
                    
                    // MARK: - 북스토리 모아보기 섹션 (최신순)
                    VStack(spacing: 20) {
                        sectionHeader(
                            title: "북스토리 모아보기",
                            gradient: [.brownLeather, .antiqueGold]
                        )
                        // TODO: - 로딩 중 상태 표시
                        PublicStoriesListView()
                            .frame(height: 350)
                    }
                    
                    spacer(height: 60)
                    
                    // MARK: - 테마별 모아보기 섹션
                    VStack(spacing: 20) {
                        sectionHeader(
                            title: "테마별 모아보기",
                            gradient: [.antiqueGold, .brownLeather]
                        )
                        
                        // TODO: - 로딩 중 상태 표시
                        PublicThemesListView()
                            .frame(height: 220)
                    }

                    spacer(height: 60)
                    
                    // MARK: - 지금 뜨고 있는 책 섹션
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
                            RandomBookListView(randomBooks: booksViewModel.books)
                                .frame(height: 320)
                        }
                    }
                    
                    spacer(height: 100) // 여유 공간
                }
                .padding(.top, 20)
            }
        }
        .refreshable {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await booksViewModel.fetchRandomBooks()
                }
                group.addTask {
                    await publicBookStoriesViewModel.refreshBookStories()
                }
                group.addTask {
                    await publicThemesViewModel.refreshThemes()
                }
            }
        }
        .task {
            // randombooks 병렬로 호출
            // TODO: 여기서 호출 한번 더??
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await booksViewModel.fetchRandomBooks()
                }
                group.addTask {
                    await publicBookStoriesViewModel.loadBookStories()
                }
                group.addTask {
                    await publicThemesViewModel.loadThemes()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavBarLogo()
            }
            ToolbarItem(placement: .topBarTrailing) {
                navBarActions()
            }
        }
    }
    
    // MARK: - UI Components

    private var heroSection: some View {
        VStack(spacing: 12) {
            Text("오늘도 좋은 문장과 함께")
                .font(.scoreDream(.bold, size: .title3))
                .foregroundStyle(Color.brown)

            Text("사람들은 어떤 책을 읽고,\n어떤 문장을 기록했을까요?")
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
                .font(.scoreDream(.bold, size: .title3))
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
                ) {
                    Image(systemName: "person.2")
                        .foregroundColor(.brownLeather)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            
            NavigationLink {
//                KeywordGroupedStoriesView(isMy: false, loadType: .public)
                EmptyView()
            } label: {
                Image(systemName: "number")
                    .foregroundColor(.brownLeather)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
}

