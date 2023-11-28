//
//  LibraryView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/07.
//

import SwiftUI
import SDWebImageSwiftUI

struct CustomTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .foregroundColor(isSelected ? .white : .secondary)
                .background(isSelected ? Color.black : Color.clear)
                .frame(minWidth: 70, minHeight: 40)
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(10)
    }
}


struct EmptyStateText: View {
    var body: some View {
        VStack {
            Image(systemName: "tray")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            Text("아직 기록이 없어요")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.gray)

            Text("지금 바로 나만의 문장을 기록해보세요")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct LibraryView: View {
    @State private var selectedView: Int = 0

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel

    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject var followViewModel = FollowViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                profileView
                CustomTabView(selectedView: $selectedView)
                tabIndicator

                Group {
                    if selectedView == 0 {
                        if myFolderViewModel.folder.isEmpty {
                            EmptyStateText()
                        } else {
                            LibraryThemaView()
                                .environmentObject(myFolderViewModel)
                                .environmentObject(userViewModel)
                                .environmentObject(myStoriesViewModel)
                        }
                    } else {
                        if myStoriesViewModel.bookStories.isEmpty {
                            EmptyStateText()
                        } else {
                            LibraryStoryView()
                                .environmentObject(myStoriesViewModel)
                                .environmentObject(userViewModel)
                        }
                    }
                }
                .gesture(
                    DragGesture().onEnded { value in
                        if value.translation.width > 0 {
                            self.selectedView = max(self.selectedView - 1, 0)
                        } else if value.translation.width < 0 {
                            self.selectedView = min(self.selectedView + 1, 1)
                        }
                    }
                )
                Spacer().frame(height: 50)

            }
            .padding(.top, 10)
        }
        .refreshable {
            await refreshContent()
        }
        .navigationBarItems(
            trailing:
                HStack {
                    leadingNavigationItem
                    trailingNavigationItem
                }
        )
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: onAppear)
    }
    
    private var tabIndicator: some View {
        let totalWidth = UIScreen.main.bounds.width
        let indicatorWidth = totalWidth * (2/3)
        let offsetWhenRight = totalWidth - indicatorWidth

        return ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.secondary)
                .frame(width: indicatorWidth, height: 2)
                .offset(x: selectedView == 0 ? 0 : offsetWhenRight)
                .animation(.easeInOut(duration: 0.2), value: selectedView)
        }
        .frame(width: totalWidth, height: 3, alignment: .leading)
    }

    private var profileView: some View {
        VStack(alignment: .center, spacing: 10) {
            WebImage(url: URL(string: userViewModel.user?.profileImage ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                .shadow(radius: 4)
                .padding(.bottom)

            Text(userViewModel.user?.nickname ?? "")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(userViewModel.user?.statusMessage ?? "")
                .font(.subheadline)
                .padding(.bottom, 10)

            HStack {
                // 팔로워 & 독서목표
                VStack {
                    NavigationLink(destination: FollowersListView(userId: userViewModel.user?.id).environmentObject(followViewModel)) {
                        VStack {
                            Text("팔로워")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(followViewModel.followersCount)")
                                .font(.headline)
                        }
                    }

                    Spacer(minLength: 20) // 여백 추가

                    Text("독서목표")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(userViewModel.user?.monthlyReadingGoal ?? 0)")
                        .font(.headline)
                }

                Spacer().frame(width: 60)
                
                // 팔로잉 & 기록 수
                VStack {
                    NavigationLink(destination: FollowingListView(userId: userViewModel.user?.id).environmentObject(followViewModel)) {
                        VStack {
                            Text("팔로잉")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("\(followViewModel.followingCount)")
                                .font(.headline)
                        }
                    }

                    Spacer(minLength: 20) // 여백 추가

                    Text("기록 수")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(userViewModel.storyCount ?? 0)")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 80)
        }
    }

    private func refreshContent() async {
        userViewModel.getProfile(userId: nil)
        userViewModel.loadStoryCount(userId: nil)
        myStoriesViewModel.refreshBookStories()
        myFolderViewModel.refreshFolders()
        followViewModel.setUserId(userViewModel.user?.id)
        followViewModel.loadFollowCounts()

    }

    private var leadingNavigationItem: some View {
        NavigationLink(destination: MySearchKeywordView().environmentObject(myStoriesViewModel).environmentObject(userViewModel)) {
            Image(systemName: "magnifyingglass").foregroundColor(Color(.systemGray)).frame(width: 25, height: 25)
        }
    }

    private var trailingNavigationItem: some View {
        NavigationLink(
            destination: SettingView()
                .environmentObject(userViewModel)
                .environmentObject(userAuthManager)
        ) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(Color(.systemGray))
                .frame(width: 25, height: 25)
        }
    }

    private func onAppear() {
        if (userAuthManager.isUserAuthenticated) {
            userViewModel.getProfile(userId: nil)
            userViewModel.loadStoryCount(userId: nil)
            myStoriesViewModel.loadBookStories()
            myFolderViewModel.loadFolders()
            followViewModel.setUserId(userViewModel.user?.id)
            followViewModel.loadFollowCounts()
        } else {
            print("토큰 만료 표시")
        }
    }
}

struct LibraryThemaView: View {
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 20
    
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(myFolderViewModel.folder, id: \.id) { folder in
                NavigationLink(destination: ThemaView(folderId: folder.id)
                    .environmentObject(myFolderViewModel)
                    .environmentObject(userViewModel)
                    .environmentObject(myStoriesViewModel))
                {
                        VStack(alignment: .leading) {
                            if let url = URL(string: folder.folderImageURL), !folder.folderImageURL.isEmpty {
                                WebImage(url: url)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: (UIScreen.main.bounds.width / 2) - 35, height: (UIScreen.main.bounds.width / 2) - 35)
                                    .cornerRadius(8)
                                    .clipped()
                                    .shadow(radius: 4)
                                
                            } else {
                                Color.gray
                                    .frame(width: (UIScreen.main.bounds.width / 2) - 35, height: (UIScreen.main.bounds.width / 2) - 35)
                                    .cornerRadius(8)
                                    .clipped()
                                    .shadow(radius: 4)
                            }
                            
                            Text(folder.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.top, 5)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom)
                }
            }
            if !myFolderViewModel.isLastPage {
                ProgressView().onAppear {
                    myFolderViewModel.loadMoreIfNeeded(currentItem: myFolderViewModel.folder.last)
                }
            }
        }
        .padding(.all, spacing)
    }
}

struct LibraryStoryView: View {
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var userViewModel: UserViewModel

    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 20
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(myStoriesViewModel.bookStories, id: \.id) { story in
                NavigationLink(destination: myBookStoryView(storyId: story.id).environmentObject(myStoriesViewModel).environmentObject(userViewModel)) {
                    VStack(alignment: .leading, spacing: 10) {
                        WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.width / 2) - 60, height: (UIScreen.main.bounds.width / 2) - 20)
                            .cornerRadius(4)
                            .clipped()
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.25), lineWidth: 1))
                        
                        Text(story.quote ?? "")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(story.content ?? "")
                            .font(.subheadline)
                        
                        Text(story.keywords?.prefix(2).map { "#\($0)" }.joined(separator: " ") ?? "")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(2) // 텍스트 줄 수 제한
                    }
                    .frame(width: (UIScreen.main.bounds.width / 2) - 60, height: 250)
                    .padding(.all, 15)
                    .background(Color(.systemBackground))
                    .cornerRadius(4)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if !myStoriesViewModel.isLastPage {
                ProgressView().onAppear {
                    myStoriesViewModel.loadMoreIfNeeded(currentItem: myStoriesViewModel.bookStories.last)
                }
            }
        }
        .padding(.all, 20)
    }
}
