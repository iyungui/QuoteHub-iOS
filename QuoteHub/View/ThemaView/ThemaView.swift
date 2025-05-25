//
//  ThemaView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/8/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ThemaView: View {
    
    let folderId: String
    @StateObject var myStoriesViewModel: BookStoriesViewModel

    init(folderId: String) {
        self.folderId = folderId
        _myStoriesViewModel = StateObject(wrappedValue: BookStoriesViewModel(folderId: folderId, mode: .myStories))
    }
    
    @State private var selectedThema: Int = 0
    @State private var showActionSheet: Bool = false
    
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel
    
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var isEditing = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView(showsIndicators: false) {
            NavigationLink(destination: UpdateThemaView(folderId: folderId).environmentObject(myFolderViewModel), isActive: $isEditing) {
                EmptyView()
            }
            VStack(spacing: 0) {
                
                ThemaImageView(folderId: folderId, selectedThema: $selectedThema)
                    .environmentObject(myFolderViewModel)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .clipped()
                
                TabIndicator
                
                Group {
                    if selectedThema == 0 {
                        GalleryGridView()
                            .environmentObject(userViewModel)
                            .environmentObject(myStoriesViewModel)

                    } else {
                        GalleryListView()
                            .environmentObject(myStoriesViewModel)
                            .environmentObject(userViewModel)
                    }
                }
            }
        }
        .refreshable {
            // Handle refresh action
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        })
        .navigationBarTitle("나의 테마별 모아보기", displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
                .frame(width: 25, height: 25)
        }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("선택"), buttons: [
                    .default(Text("수정하기"), action: {
                        isEditing = true
                    }),
                    .destructive(Text("삭제하기"), action: {
                        myFolderViewModel.deleteFolder(folderId: folderId) { isSuccess in
                            if isSuccess {
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                alertMessage = "테마 삭제 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                                showAlert = true
                            }
                        }
                    }),
                    .cancel() // 취소 버튼
                ])
            }
        )
    }
    
    private var TabIndicator: some View {
        let totalWidth = UIScreen.main.bounds.width
        let indicatorWidth = totalWidth * (2/3)
        let offsetWhenRight = totalWidth - indicatorWidth

        return ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.secondary)
                .frame(width: indicatorWidth, height: 3)
                .offset(x: selectedThema == 0 ? 0 : offsetWhenRight)
                .animation(.easeInOut(duration: 0.2), value: selectedThema)
        }
        .frame(width: totalWidth, height: 3, alignment: .leading)
    }
}


struct ThemaImageView: View {
    let folderId: String
    @Binding var selectedThema: Int
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel


    var body: some View {
        if let folder = myFolderViewModel.folder.first(where: { $0.id == folderId }) {
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
                        Text(folder.isPublic ? "공개" : "비공개")
                            .font(.caption)
                            .foregroundColor(.white)
                        Image(systemName: folder.isPublic ? "lock.open.fill" : "lock.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
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
                    }
                    .padding([.horizontal, .bottom], 20)
                }
                
            }
        } else {
            Text("해당 테마를 찾을 수 없습니다.")
        }
    }
}



struct GalleryGridView: View {
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 3) {
            ForEach(myStoriesViewModel.bookStories, id: \.id) { story in
                NavigationLink(destination: myBookStoryView(storyId: story.id).environmentObject(myStoriesViewModel).environmentObject(userViewModel)) {
                    WebImage(url: URL(string: story.storyImageURLs?.first ?? ""))
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
                        .clipped()
                }
            }
            if !myStoriesViewModel.isLastPage {
                ProgressView().onAppear {
                    myStoriesViewModel.loadMoreIfNeeded(currentItem: myStoriesViewModel.bookStories.last)
                }
            }
        }
    }
}


struct GalleryListView: View {
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(myStoriesViewModel.bookStories, id: \.id) { story in
                NavigationLink(destination: myBookStoryView(storyId: story.id).environmentObject(myStoriesViewModel).environmentObject(userViewModel)) {
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
            
            if !myStoriesViewModel.isLastPage {
                ProgressView().onAppear {
                    myStoriesViewModel.loadMoreIfNeeded(currentItem: myStoriesViewModel.bookStories.last)
                }
            }
        }
        .padding(.top)
    }
}
