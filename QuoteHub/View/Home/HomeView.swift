//
//  HomeView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @State private var selectedTab: Int = 0
    let numberOfTabs = 3
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    @StateObject var booksViewModel = RandomBooksViewModel()
    @StateObject var folderViewModel = FolderViewModel()
    
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel
    
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @StateObject var storiesViewModel = BookStoriesViewModel(mode: .public)
    
    var body: some View {
        ScrollView {
            VStack {
//                spacer(height: 10)
//                pagedRectangles()
                spacer(height: 30)
                                
                sectionHeader(title: "최신 북스토리 모아보기")
                ListPublicStoriesView(storiesViewModel: storiesViewModel).environmentObject(userViewModel)
                    .environmentObject(myStoriesViewModel).environmentObject(userAuthManager)
                    .frame(height: 350)
                spacer(height: 50)
                
                sectionHeader(title: "테마별 모아보기")
                ListThemaView(viewModel: folderViewModel)
                    .environmentObject(userAuthManager)
                    .environmentObject(myFolderViewModel)
                    .environmentObject(userViewModel)
                    .environmentObject(myStoriesViewModel)
                    .frame(height: 200)

                spacer(height: 60)
                
                sectionHeader(title: "지금 뜨고 있는 책")
                spacer(height: 30)
            
                if booksViewModel.isLoading {
                    ProgressView()
                } else {
                    horizontalBookScroll()
                        .frame(height: 300)
                }
                spacer(height: 10)
            }
        }
        .refreshable {
            await refreshContent()
        }
        .navigationBarItems(
            leading: navBarLogo()
            ,trailing:
                HStack(spacing: 15) {
                    if userAuthManager.isUserAuthenticated {
                        NavigationLink(destination: UserSearchView().environmentObject(storiesViewModel).environmentObject(userAuthManager)) {
                            Image(systemName: "person.2").foregroundColor(Color(.systemGray)).frame(width: 25, height: 25)
                        }
                    }
                    
                    NavigationLink(destination: SearchKeywordView(
                    ).environmentObject(userViewModel).environmentObject(myStoriesViewModel).environmentObject(userAuthManager)) {
                        Image(systemName: "magnifyingglass").foregroundColor(Color(.systemGray)).frame(width: 25, height: 25)
                    }
                }
        )
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
    
    func pagedRectangles() -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            TabView(selection: $selectedTab) {
                ForEach(1..<numberOfTabs) { index in
                    Image("preview_\(index)")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: width)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .animation(.easeInOut)
            .transition(.slide)
            .onReceive(timer) { _ in
                selectedTab = (selectedTab + 1) % numberOfTabs
            }
        }
        .frame(height: UIScreen.main.bounds.width)
    }

    func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.leading, 30)
    }
    
    func horizontalBookScroll() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(booksViewModel.books, id: \.id) { book in

                    NavigationLink(destination: BookDetailView(book: book)
                        .environmentObject(userAuthManager)
                        .environmentObject(myFolderViewModel)
                        .environmentObject(myStoriesViewModel)
                    ) {
                        VStack(alignment: .center, spacing: 10) {
                            // story Image
                            WebImage(url: URL(string: book.bookImageURL ?? ""))
                                .placeholder {
                                    Rectangle().foregroundColor(.clear)
                                }
                                .resizable()
                                .indicator(.activity)
                                .transition(.fade(duration: 0.5))
                                .scaledToFill()
                                .frame(width: 100, height: 150)
                                .border(Color.gray.opacity(0.5), width: 1)
                                .clipped()
                            
                            VStack(alignment: .leading, spacing: 2.5) {
                                Text(book.title ?? "제목 없음")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                Text(book.author?.joined(separator: ", ") ?? "")
                                    .font(.caption2)
                                    .fontWeight(.thin)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                            }
                            .frame(width: 140)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 10)
            .padding(.leading)
        }
        .onAppear(perform: booksViewModel.getRandomBooksIfNeeded)
    }
    
    func navBarLogo() -> some View {
        Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .padding(.vertical)
            .foregroundColor(.accentColor)
    }
}
