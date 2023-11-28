//
//  PublicThemaView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/12/23.
//

import SwiftUI
import SDWebImageSwiftUI

enum BlockedAlertType {
    case loginRequired
    case blocked
}

struct PublicThemaView: View {

    let folder: Folder
    
    @StateObject private var bookStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var viewModel: FolderViewModel

    @State private var FriendselectedThema: Int = 0

    init(folder: Folder) {
        self.folder = folder
        self._bookStoriesViewModel = StateObject(wrappedValue: BookStoriesViewModel(folderId: folder.id, mode: .public))
        self._followViewModel = StateObject(wrappedValue: FollowViewModel(userId: folder.userId.id))

    }
    
    @StateObject private var followViewModel: FollowViewModel
    @State private var showAlert: Bool = false
    @State private var alertType: BlockedAlertType = .loginRequired
    @State private var alertMessage = ""
    @State private var showActionSheet = false
    @ObservedObject var userAuthManager = UserAuthenticationManager.shared

    @StateObject var reportViewModel = ReportViewModel()
    @State private var reportReason = ""
    @State private var showReportSheet = false
    
    var body: some View {
        Group {
            if followViewModel.isBlocked {
                VStack {
                    Spacer()
                    Image(systemName: "person.crop.circle.badge.xmark.fill")
                        .font(.headline)
                        .padding()
                    Text("차단된 사용자입니다.\n설정의 차단 목록에서 확인해주세요.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        PublicThemaImageView(folderId: folder.id, selectedThema: $FriendselectedThema)
                            .environmentObject(viewModel)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                            .clipped()
                        
                        TabIndicator

                        Group {
                            if FriendselectedThema == 0 {
                                PublicGalleryGridView()
                                    .environmentObject(bookStoriesViewModel)
                            } else {
                                PublicGalleryListView()
                                    .environmentObject(bookStoriesViewModel)
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
                .alert(isPresented: $showAlert) {
                    switch alertType {
                    case .loginRequired:
                        return Alert(
                            title: Text("로그인 필요"),
                            message: Text("이 기능을 사용하려면 로그인이 필요합니다."),
                            dismissButton: .default(Text("확인"))
                        )
                    case .blocked:
                        return Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                    }
                }
                .navigationBarItems(trailing:
                                        Button(action: {
                    showActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                })
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("선택"), buttons: [
                        .default(Text("차단하기"), action: {
                            if userAuthManager.isUserAuthenticated {
                                blockUser()
                            } else {
                                alertType = .loginRequired
                                showAlert = true
                            }
                        }),
                        .destructive(Text("신고하기"), action: {
                            if userAuthManager.isUserAuthenticated {
                                showReportSheet = true
                            } else {
                                alertType = .loginRequired
                                showAlert = true
                            }
                        }),
                        .cancel() // 취소 버튼
                    ])
                }
                .sheet(isPresented: $showReportSheet) {
                    UserReportSheetView(reportViewModel: reportViewModel, userId: folder.userId.id, reportReason: $reportReason).environmentObject(followViewModel)
                }
                .navigationBarTitle("테마별 모아보기", displayMode: .inline)
            }
        }
        .onAppear {
            followViewModel.updateFollowStatus(userId: folder.userId.id)
        }
    }
    
    private func blockUser() {
        FollowService().updateFollowStatus(userId: folder.userId.id, status: "BLOCKED") { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.alertType = .blocked
                    followViewModel.updateFollowStatus(userId: folder.userId.id)
                }

            case .failure(let error):
                self.alertType = .blocked
                self.alertMessage = "오류: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
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

struct PublicThemaImageView: View {
    let folderId: String
    @EnvironmentObject var viewModel: FolderViewModel
    @Binding var selectedThema: Int

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

struct PublicGalleryGridView: View {
    @EnvironmentObject var bookStoriesViewModel: BookStoriesViewModel
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 3) {
            ForEach(bookStoriesViewModel.bookStories, id: \.id) { story in
                NavigationLink(destination: friendBookStoryView(story: story)) {
                    WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                        .clipped()
                }
            }
            if !bookStoriesViewModel.isLastPage {
                ProgressView().onAppear {
                    bookStoriesViewModel.loadMoreIfNeeded(currentItem: bookStoriesViewModel.bookStories.last)
                }
            }
        }
    }
}

struct PublicGalleryListView: View {
    @EnvironmentObject var bookStoriesViewModel: BookStoriesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(bookStoriesViewModel.bookStories, id: \.id) { story in
                NavigationLink(destination: friendBookStoryView(story: story).environmentObject(bookStoriesViewModel)) {
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
            if !bookStoriesViewModel.isLastPage {
                ProgressView().onAppear {
                    bookStoriesViewModel.loadMoreIfNeeded(currentItem: bookStoriesViewModel.bookStories.last)
                }
            }
        }
    }
}

