//
//  HomeView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @StateObject var booksViewModel = RandomBooksViewModel()
    @StateObject var folderViewModel = FolderViewModel()
    
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel
    
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @StateObject var storiesViewModel = BookStoriesViewModel(mode: .public)
    
    var body: some View {
        ZStack {
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
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection()
                    
                    spacer(height: 40)
                    
                    // 최신 북스토리 섹션
                    VStack(spacing: 20) {
                        sectionHeader(
                            title: "북스토리 모아보기",
                            gradient: [.brownLeather, .antiqueGold]
                        )
                        
                        ListPublicStoriesView(storiesViewModel: storiesViewModel)
                            .environmentObject(userViewModel)
                            .environmentObject(myStoriesViewModel)
                            .environmentObject(userAuthManager)
                            .frame(height: 350)
                    }
                    
                    spacer(height: 60)
                    
                    // 테마별 모아보기 섹션
                    VStack(spacing: 20) {
                        sectionHeader(
                            title: "테마별 모아보기",
                            gradient: [.antiqueGold, .brownLeather]
                        )
                        
                        ListThemaView(viewModel: folderViewModel)
                            .environmentObject(userAuthManager)
                            .environmentObject(myFolderViewModel)
                            .environmentObject(userViewModel)
                            .environmentObject(myStoriesViewModel)
                            .frame(height: 220)
                    }

                    spacer(height: 60)
                    
                    // 지금 뜨고 있는 책 섹션
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
                            horizontalBookScroll()
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
        .navigationBarItems(
            leading: navBarLogo(),
            trailing: navBarActions()
        )
    }
    
    // MARK: - Hero Section
    private func heroSection() -> some View {
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
    
    private func refreshContent() async {
        booksViewModel.getRandomBooks()
        storiesViewModel.refreshBookStories()
        folderViewModel.refreshFolders()
    }

    // MARK: - Components
    
    func spacer(height: CGFloat) -> some View {
        Spacer().frame(height: height)
    }

    func sectionHeader(title: String, gradient: [Color]) -> some View {
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
    
    func horizontalBookScroll() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(booksViewModel.books.enumerated()), id: \.element.id) { _, book in
                    NavigationLink(destination: BookDetailView(book: book)
                        .environmentObject(userAuthManager)
                        .environmentObject(myFolderViewModel)
                        .environmentObject(myStoriesViewModel)
                    ) {
                        bookCard(book: book)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 30)
        }
        .onAppear(perform: booksViewModel.getRandomBooksIfNeeded)
    }
    
    private func bookCard(book: Book) -> some View {
        VStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .topLeading) {
                // 책 이미지
                WebImage(url: URL(string: book.bookImageURL ?? ""))
                    .placeholder {
                        Rectangle()
                            .fill(Color.paperBeige.opacity(0.3))
                            .overlay(
                                Image(systemName: "book.closed")
                                    .foregroundColor(.brownLeather)
                                    .font(.largeTitle)
                            )
                    }
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.antiqueGold.opacity(0.4), lineWidth: 1)
                    )
                    .shadow(color: .brownLeather.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            VStack(alignment: .center, spacing: 6) {
                Text(book.title ?? "제목 없음")
                    .font(.scoreDream(.medium, size: .caption))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(.primaryText)
                
                Text(book.author?.joined(separator: ", ") ?? "")
                    .font(.scoreDream(.light, size: .footnote))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(.secondaryText)
            }
            .frame(width: 140)
        }
        .padding(.horizontal, 10)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: booksViewModel.isLoading)
    }
    
    func navBarLogo() -> some View {
        HStack(spacing: 8) {
            Image("logo")
                .resizable().scaledToFit().frame(height: 24)
            
            Text("문장모아")
                .font(.custom("EF_jejudoldam", size: 17))
                .foregroundStyle(Color.appAccent)
        }
    }
    
    private func navBarActions() -> some View {
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
            
            NavigationLink(destination: SearchKeywordView()
                .environmentObject(userViewModel)
                .environmentObject(myStoriesViewModel)
                .environmentObject(userAuthManager)
            ) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.brownLeather)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
}
