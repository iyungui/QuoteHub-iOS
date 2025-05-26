//
//  friendBookStoryView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/12.
//

import SwiftUI
import SDWebImageSwiftUI

enum LinkAlertType {
    case loginRequired
    case link
    case blocked
}

struct friendBookStoryView: View {
    let story: BookStory
    @EnvironmentObject var viewModel: BookStoriesViewModel

    @Environment(\.colorScheme) var colorScheme

    @State private var isExpanded: Bool = false

    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var commentViewModel: CommentViewModel
    @State private var showAlert: Bool = false
    @State private var alertType: LinkAlertType = .link
    @State private var alertMessage = ""

    init(story: BookStory) {
        self.story = story
        self._commentViewModel = StateObject(wrappedValue: CommentViewModel(bookStoryId: story.id))
        self._followViewModel = StateObject(wrappedValue: FollowViewModel(userId: story.userId.id))
    }
    
    @State private var showActionSheet = false

    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    
    @StateObject var reportViewModel = ReportViewModel()
    @State private var reportReason = ""
    @State private var showReportSheet = false
    @StateObject private var followViewModel: FollowViewModel
    
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
                ScrollView {
                    VStack {
                        // PAGE 1
                        Divider()
                        keywordView
                        quoteView
                        storyImagesView
                        NavigationLink(destination: FriendLibraryView(friendId: story.userId).environmentObject(userAuthManager)) {
                            profileView
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        storyContentView
                        // PAGE 2
                        infoBookView
                        Spacer().frame(minHeight: 50)
                        HStack {
                            Spacer()
                            Text("작성일: \(story.updatedAtDate)")
                                .padding(.trailing)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Divider()
                        
                        VStack {
                            Button(action: {
                                if userAuthManager.isUserAuthenticated {
                                    isExpanded.toggle()
                                } else {
                                    alertType = .loginRequired
                                    showAlert = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.accentColor)
                                        .padding()
                                    Text("\(commentViewModel.totalCommentCount)")
                                        .font(.headline)
                                    Spacer()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
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
                    case .link:
                        return Alert(
                            title: Text("외부 사이트로 이동"),
                            message: Text("이 책에 대한 추가 정보를 외부 사이트에서 제공합니다. 외부 링크를 통해 해당 정보를 보시겠습니까?"),
                            primaryButton: .default(Text("확인")) {
                                if let url = URL(string: story.bookId.bookLink) {
                                    UIApplication.shared.open(url)
                                }
                            },
                            secondaryButton: .cancel()
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
                .sheet(isPresented: $isExpanded) {
                    CommentView(viewModel: commentViewModel)
                }
                .sheet(isPresented: $showReportSheet) {
                    ReportSheetView(reportViewModel: reportViewModel, story: story, reportReason: $reportReason).environmentObject(followViewModel)
                }
                .onTapGesture {
                    hideKeyboard()
                }
                .refreshable {
                    commentViewModel.refreshComments()
                }
            }
        }
        .onAppear {
            if userAuthManager.isUserAuthenticated {
                followViewModel.updateFollowStatus(userId: story.userId.id)
            } else {
                print("No Authorization Token Found for Friend Book Story")
            }
        }
    }
    
    private func blockUser() {
        FollowService().updateFollowStatus(userId: story.userId.id, status: "BLOCKED") { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.alertType = .blocked
                    followViewModel.updateFollowStatus(userId: story.userId.id)
                }

            case .failure(let error):
                self.alertType = .blocked
                self.alertMessage = "오류: \(error.localizedDescription)"
                self.showAlert = true
            }
        }
    }
    
    // MARK: - PAGE 1
    
    private var keywordView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(story.keywords ?? [], id: \.self) { keyword in
                    Text("#\(keyword)")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding(.leading, 20)
        }
        .padding(.top, 10)
    }
    
    private var quoteView: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Text("“")
                    .font(.largeTitle)
                    .fontWeight(.black)
                Spacer()
            }
            
            Text(story.quote ?? "")
                .frame(minHeight: 100)
                .padding(.horizontal)
            
            HStack {
                Spacer()
                Text("”")
                    .font(.largeTitle)
                    .fontWeight(.black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
    }
    
    private var storyImagesView: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            TabView {
                ForEach(story.storyImageURLs ?? [], id: \.self) { index in
                    WebImage(url: URL(string: index))
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: width)
                        .clipped()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(width: width, height: width)
        }
        .frame(height: UIScreen.main.bounds.width)
    }
    
    private var profileView: some View {
        HStack {
            if let url = URL(string: story.userId.profileImage), !story.userId.profileImage.isEmpty {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }

            VStack(alignment: .leading, spacing: 15) {
                Text(story.userId.nickname)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(story.userId.statusMessage ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

            }
            .padding(.leading, 10)
            
            Spacer()
            Image(systemName: "chevron.right")
                .fontWeight(.medium)
                .foregroundColor(.gray)
        }
        .padding(.all, 10)
        .cornerRadius(12)
        .padding(.horizontal)
        
    }
    
    private var storyContentView: some View {
        VStack(alignment: .leading) {
            Text(story.content ?? "Content")
                .font(.body)
                .frame(minHeight: 50)
                .padding()
        }
        .padding(.horizontal)
    }
    
    // MARK: - PAGE 2
    private var infoBookView: some View {
        Button(action: {
            self.alertType = .link
            self.showAlert = true
        }) {
            // infoBookView
            HStack {
                WebImage(url: URL(string: story.bookId.bookImageURL))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 100)
                    .cornerRadius(4)
                    .shadow(radius: 3)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(story.bookId.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(story.bookId.author.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(story.bookId.publisher)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .fontWeight(.medium)
                    .foregroundColor(.gray)

            }
            .padding(.all, 10)
            .padding(.horizontal)
        }
        .buttonStyle(MyActionButtonStyle())
        
    }
}
