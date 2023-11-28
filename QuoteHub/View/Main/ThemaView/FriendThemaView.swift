//
//  FriendThemaView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/8/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendThemaView: View {
    
    let folderId: String
    let friendId: User

    @StateObject private var viewModel: BookStoriesViewModel

    init(folderId: String, friendId: User) {
        self.friendId = friendId
        self.folderId = folderId
        self._viewModel = StateObject(wrappedValue: BookStoriesViewModel(folderId: folderId, mode: .friendStories(friendId.id)))
    }
    
    @State private var FriendselectedThema: Int = 0
    
    @EnvironmentObject var FolderViewModel: FriendFolderViewModel
    @EnvironmentObject var userViewModel: UserViewModel
        
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                
                FriendThemaImageView(folderId: folderId, selectedThema: $FriendselectedThema)
                    .environmentObject(FolderViewModel)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .clipped()
                
                TabIndicator

                Group {
                    if FriendselectedThema == 0 {
                        FriendGalleryGridView()
                            .environmentObject(viewModel)
                    } else {
                        FriendGalleryListView()
                            .environmentObject(viewModel)
                    }
                }
                .gesture(
                    DragGesture().onEnded { value in
                        if value.translation.width > 0 {
                            self.FriendselectedThema = max(self.FriendselectedThema - 1, 0)
                        } else if value.translation.width < 0 {
                            self.FriendselectedThema = min(self.FriendselectedThema + 1, 1)
                        }
                    }
                )
            }
        }
        .navigationBarTitle("테마별 모아보기", displayMode: .inline)
    }
    private var TabIndicator: some View {
        let totalWidth = UIScreen.main.bounds.width
        let indicatorWidth = totalWidth * (2/3)
        let offsetWhenRight = totalWidth - indicatorWidth

        return ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.secondary)
                .frame(width: indicatorWidth, height: 3)
                .offset(x: FriendselectedThema == 0 ? 0 : offsetWhenRight)
                .animation(.easeInOut(duration: 0.2), value: FriendselectedThema)
        }
        .frame(width: totalWidth, height: 3, alignment: .leading)
    }
}

struct FriendThemaImageView: View {
    let folderId: String
    @Binding var selectedThema: Int

    @EnvironmentObject var viewModel: FriendFolderViewModel

    var body: some View {
        if let folder = viewModel.folder.first(where: { $0.id == folderId
        }) {
            ZStack {
                
                if let url = URL(string: folder.folderImageURL), !folder.folderImageURL.isEmpty {
                    WebImage(url: url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                } else {
                    Color.gray
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                }

                GeometryReader { geometry in
                    Rectangle()
                        .foregroundColor(.black.opacity(0.5))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
                
                HStack {
                    VStack {
                        VStack(alignment: .leading) {
                            Text(folder.name)
                                .font(.title)
                                .foregroundColor(.white)
                            Text(folder.description)
                                .font(.body)
                                .foregroundColor(.white)
                            Text("작성일: \(folder.updatedAtDate)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding([.top, .leading], 20)
                        Spacer()
                    }
                    Spacer()
                }

                VStack {
                    Spacer()
                    HStack(spacing: 10) {
                        Button(action: {
                            withAnimation {
                                self.selectedThema = 0
                            }
                        }) {
                            Image(systemName: "square.grid.2x2")
                                .foregroundColor(selectedThema == 0 ? Color.appAccent : .gray)
                                .scaleEffect(selectedThema == 0 ? 1.2 : 1.0)  // Slightly larger when selected
                        }

                        Button(action: {
                            withAnimation {
                                self.selectedThema = 1
                            }
                        }) {
                            Image(systemName: "list.dash")
                                .foregroundColor(selectedThema == 1 ? Color.appAccent : .gray)
                                .scaleEffect(selectedThema == 1 ? 1.2 : 1.0)  // Slightly larger when selected
                        }
                        Spacer()
                        
                        NavigationLink(destination: FriendLibraryView(friendId: folder.userId)) {
                            VStack(alignment: .trailing, spacing: 10) {
                                WebImage(url: URL(string: folder.userId.profileImage))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                Text(folder.userId.nickname)
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                }
            }
        } else {
            Text("해당 테마를 찾을 수 없습니다.")
        }
    }
}

struct FriendGalleryGridView: View {
    @EnvironmentObject var viewModel: BookStoriesViewModel
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 3) {
            ForEach(viewModel.bookStories, id: \.id) { story in
                NavigationLink(destination: friendBookStoryView(story: story).environmentObject(viewModel)) {
                    WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                        .clipped()
                }
            }
            if !viewModel.isLastPage {
                ProgressView().onAppear {
                    viewModel.loadMoreIfNeeded(currentItem: viewModel.bookStories.last)
                }
            }
        }
    }
}


struct FriendGalleryListView: View {
    @EnvironmentObject var viewModel: BookStoriesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(viewModel.bookStories, id: \.id) { story in
                NavigationLink(destination: friendBookStoryView(story: story).environmentObject(viewModel)) {
                    HStack {
                        Text(story.quote ?? "")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                        WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 85, height: 85)
                            .clipped()
                    }
                    .padding(10)
                    .padding(.horizontal, 10)
                }
                
                Divider()
            }
            if !viewModel.isLastPage {
                ProgressView().onAppear {
                    viewModel.loadMoreIfNeeded(currentItem: viewModel.bookStories.last)
                }
            }
        }
    }
}

