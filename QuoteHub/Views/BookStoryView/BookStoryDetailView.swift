//
//  BookStoryDetailView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/12.
//

import SwiftUI
import SDWebImageSwiftUI

enum StoryAlertType {
    case loginRequired  // 게스트 로그인 시 로그인 알림
    case link   // 책 상세 페이지로 이동 전 알림
    case blocked    // 현재 북스토리 올린 상대방이 차단 상태인지 확인
}

/// 북스토리 상세 뷰. isMyStory가 true인 경우, 내 북스토리 뷰 (삭제, 수정 가능)
/// isMyStory가 false 인 경우, 상대방 스토리 뷰 (차단/신고 가능)

struct BookStoryDetailView: View {
    
    // MARK: - PROPERTIES
    
    let story: BookStory
    let isMyStory: Bool
    
    // view model
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @StateObject private var commentViewModel: CommentViewModel
    
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    
    // 친구 스토리 전용
    @StateObject private var followViewModel: FollowViewModel   // 차단상태확인 위해
    // (차단 여부는 followViewModel.updateFollowStatus 로 확인 가능)
    @StateObject var reportViewModel: ReportViewModel
    
    
    // 다크모드 대응
    @Environment(\.colorScheme) var colorScheme
    
    // 뒤로가기
    @Environment(\.dismiss) var dismiss
    
    // 댓글창 on off
    @State private var isExpanded: Bool = false
    
    // 알림 관련
    @State private var showAlert: Bool = false
    @State private var alertType: StoryAlertType = .link
    @State private var alertMessage = ""
    
    // 신고, 차단 sheet on off
    @State private var showActionSheet = false
    @State private var reportReason = ""
    @State private var showReportSheet = false
    
    // 내 스토리 초기화
    init(story: BookStory, isMyStory: Bool) {
        self.story = story
        self.isMyStory = isMyStory
        self._commentViewModel = StateObject(wrappedValue: CommentViewModel(bookStoryId: story.id))
        self._followViewModel = StateObject(wrappedValue: FollowViewModel())
        self._reportViewModel = StateObject(wrappedValue: ReportViewModel())
    }
    
    // 친구 스토리 초기화
    init(story: BookStory) {
        self.story = story
        self.isMyStory = false
        self._commentViewModel = StateObject(wrappedValue: CommentViewModel(bookStoryId: story.id))
        self._followViewModel = StateObject(wrappedValue: FollowViewModel(userId: story.userId.id))
        self._reportViewModel = StateObject(wrappedValue: ReportViewModel())
    }
    
    // MARK: - BODY
    
    var body: some View {
        Group {
            if followViewModel.isBlocked {
                ContentUnavailableView("차단된 사용자", systemImage: "person.crop.circle.badge.xmark.fill", description: Text("설정의 차단 목록에서 확인해주세요."))
            } else {
                mainContent
            }
        }
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                navBarButton
            }
        }
        
        // 북스토리 신고, 차단 액션 시트
        .confirmationDialog("", isPresented: $showActionSheet) { actionSheetView }
        
        // 알림
        .alert(isPresented: $showAlert) { alertView }
        
        
        // 댓글창
        .sheet(isPresented: $isExpanded) {
            // TODO: - observedObject -> EnvironmentObject
            CommentView(viewModel: commentViewModel)
        }
        
        // 북스토리 차단 시트
        .sheet(isPresented: $showReportSheet) {
            ReportSheetView(story: story, reportReason: $reportReason)
                .environmentObject(followViewModel)
        }
        
        // 새로고침
        // TODO: - 단일 북스토리 조회 API 가져오기 getBookStory(story: story)
        .refreshable {
            
        }
        
        // onAppear -> task (비동기 처리)
        .onAppear { confirmBlockedStatus() }
    }
    
    // MARK: - VIEW COMPONENTS
    
    @ViewBuilder
    private var mainContent: some View {
        ScrollView {
            VStack {
                keywordSection
                quoteSection
                storyImagesSection
                profileSection
                storyContentSection
                bookInfoSection
                
                Spacer().frame(minHeight: 50)
                
                // 스토리 정보 (공개/비공개 정보는 내 스토리에서만)
                storyInfoSection
                
                Divider()
                
                // 댓글 버튼
                commentButton
            }
        }
    }
    
    // 키워드 가로스크롤 섹션
    private var keywordSection: some View {
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
    
    /// 문장 인용구 섹션
    private var quoteSection: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Text("“")
                    .font(.largeTitle)
                    .fontWeight(.black)
                Spacer()
            }
            
            AnimatedText(.constant(story.quote ?? ""))
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
    
    // 스토리 이미지 섹션
    @ViewBuilder
    private var storyImagesSection: some View {
        let width: CGFloat = UIScreen.main.bounds.width
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
    
    // 프로필 이미지 섹션
    @ViewBuilder
    private var profileSection: some View {
        if isMyStory {
            // 내 스토리 - 내 프로필 정보 표시
            HStack {
                if let url = URL(string: userViewModel.user?.profileImage ?? ""), !(userViewModel.user?.profileImage ?? "").isEmpty {
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
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(userViewModel.user?.nickname ?? "닉네임 없음")
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(userViewModel.user?.statusMessage ?? "")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
                .padding(.leading, 10)
                
                Spacer()
            }
            .padding(.all, 10)
            .cornerRadius(12)
            .padding(.horizontal)
        } else {
            // 친구 스토리 - 친구 프로필 정보 표시 + NavigationLink
            NavigationLink(
                destination: LibraryView(user: story.userId)
                    .environmentObject(userAuthManager)
                    .environmentObject(userViewModel)
                    .environmentObject(storiesViewModel)
                    .environmentObject(themesViewModel)
            ) {
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
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // 스토리 컨텐츠 섹션
    private var storyContentSection: some View {
        VStack(alignment: .leading) {
            Text(story.content ?? "")
                .font(.body)
                .frame(minHeight: 50)
                .padding()
        }
        .padding(.horizontal)
    }
    
    // TODO: - 여기서부터 page 2로 만들기 (스크롤뷰 조정)
    
    // 책 정보
    private var bookInfoSection: some View {
        Button(action: {
            self.alertType = .link
            self.showAlert = true
        }) {
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
    
    // 스토리 정보 (작성일, 잠금여부)
    private var storyInfoSection: some View {
        HStack {
            Spacer()
            
            // 내 스토리에서만 공개/비공개 표시
            if isMyStory {
                Text(story.isPublic ? "공개" : "비공개")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Image(systemName: story.isPublic ? "lock.open.fill" : "lock.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            
            Text("작성일: \(story.updatedAt.prefix(10))")
                .padding(.trailing)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    // 댓글 버튼
    private var commentButton: some View {
        
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
    
    // MARK: - NAVIGATION & ACTIONS
    
    private var navBarButton: some View {
        Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
        }
    }
    
    private func confirmBlockedStatus() {
        if !isMyStory {
            // 친구 스토리인 경우 차단 상태 확인
            if userAuthManager.isUserAuthenticated {
                followViewModel.updateFollowStatus(userId: story.userId.id)
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
    
    private var alertView: Alert {
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
            return Alert(
                title: Text("알림"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
    }
    
    @ViewBuilder
    private var actionSheetView: some View {
        if isMyStory {
            // 내 스토리 - 편집/삭제
            Button("수정하기") {
                // TODO: - UpdateStoryView 네비게이션 로직
            }
            
            Button("삭제하기", role: .destructive) {
                storiesViewModel.deleteBookStory(storyID: story.id) { isSuccess in
                    if isSuccess {
                        dismiss()
                    }
                }
            }
            
            Button("취소", role: .cancel) { }
            
        } else {
            // 친구 스토리 - 차단/신고
            Button("차단하기") {
                if userAuthManager.isUserAuthenticated {
                    blockUser()
                } else {
                    alertType = .loginRequired
                    showAlert = true
                }
            }
            
            Button("신고하기", role: .destructive) {
                if userAuthManager.isUserAuthenticated {
                    showReportSheet = true
                } else {
                    alertType = .loginRequired
                    showAlert = true
                }
            }
            
            Button("취소", role: .cancel) { }
        }
    }
}
