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
    @State private var alertType: StoryAlertType = .loginRequired
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
        ZStack {
            backgroundGradient
            
            Group {
                if followViewModel.isBlocked {
                    ContentUnavailableView("차단된 사용자", systemImage: "person.crop.circle.badge.xmark.fill", description: Text("설정의 차단 목록에서 확인해주세요."))
                } else {
                    mainContent
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.softBeige.opacity(0.3),
                Color.lightPaper.opacity(0.2),
                Color.paperBeige.opacity(0.1)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                keywordSection
                quoteSection
                storyImagesSection
                profileSection
                storyContentSection
                bookInfoSection
                
                spacer(height: 20)
                
                // 스토리 정보 (공개/비공개 정보는 내 스토리에서만)
                storyInfoSection
                
                Divider()
                    .foregroundStyle(Color.secondaryText.opacity(0.3))
                    .padding(.horizontal, 20)
                
                // 댓글 버튼
                commentButton
                
                spacer(height: 100)
            }
            .padding(.top, 20)
        }
    }
    
    // 키워드 가로스크롤 섹션
    private var keywordSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(story.keywords ?? [], id: \.self) { keyword in
                    Text("#\(keyword)")
                        .font(.scoreDream(.medium, size: .subheadline))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.brownLeather, .antiqueGold]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .brownLeather.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    /// 문장 인용구 섹션
    private var quoteSection: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack {
                Text("“")
                    .font(.scoreDream(.black, size: .largeTitle))
                    .foregroundColor(.brownLeather.opacity(0.8))
                Spacer()
            }
            
            
            AnimatedText(.constant(story.firstQuoteText))
                .font(.scoreDream(.medium, size: .body))
                .foregroundColor(.primaryText)
                .lineSpacing(6)
                .frame(minHeight: 100)
                .padding(.horizontal, 20)
            
            HStack {
                Spacer()
                Text("“")
                    .font(.scoreDream(.black, size: .largeTitle))
                    .foregroundColor(.brownLeather.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // 스토리 이미지 섹션
    @ViewBuilder
    private var storyImagesSection: some View {
        if let imageUrls = story.storyImageURLs, !imageUrls.isEmpty {
            let width: CGFloat = UIScreen.main.bounds.width
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, imageUrl in
                        VStack {
                            ZStack {
                                WebImage(url: URL(string: imageUrl))
                                    .placeholder {
                                        Rectangle()
                                            .fill(Color.paperBeige.opacity(0.3))
                                            .overlay(
                                                VStack(spacing: 12) {
                                                    Image(systemName: "photo")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.brownLeather.opacity(0.6))
                                                    Text("이미지 로딩 중...")
                                                        .font(.scoreDream(.light, size: .caption))
                                                        .foregroundColor(.secondaryText)
                                                }
                                            )
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: width - 50)
                                    .scrollTransition(axis: .horizontal) { content, phase in
                                        content
                                            .offset(x: phase.isIdentity ? 0 : phase.value * -200)
                                    }
                            }
                            .containerRelativeFrame(.horizontal)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
            }
            .contentMargins(32)
            .scrollTargetBehavior(.paging)
            .frame(height: width - 30) // 전체 높이 설정
        }
    }
    // 프로필 이미지 섹션
    @ViewBuilder
    private var profileSection: some View {
        if isMyStory {
            // 내 스토리 - 내 프로필 정보 표시
            HStack(spacing: 16) {
                profileImage(for: userViewModel.user)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(userViewModel.user?.nickname ?? "닉네임 없음")
                        .font(.scoreDream(.bold, size: .body))
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(userViewModel.user?.statusMessage ?? "")
                        .font(.scoreDream(.medium, size: .subheadline))
                        .foregroundColor(.secondaryText)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        } else {
            // 친구 스토리 - 친구 프로필 정보 표시 + NavigationLink
            NavigationLink(
                destination: LibraryView(user: story.userId)
                    .environmentObject(userAuthManager)
                    .environmentObject(userViewModel)
                    .environmentObject(storiesViewModel)
                    .environmentObject(themesViewModel)
            ) {
                HStack(spacing: 16) {
                    profileImage(for: story.userId)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(story.userId.nickname)
                            .font(.scoreDream(.bold, size: .body))
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(story.userId.statusMessage ?? "")
                            .font(.scoreDream(.medium, size: .subheadline))
                            .foregroundColor(.secondaryText)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondaryText.opacity(0.6))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .buttonStyle(CardButtonStyle())
        }
    }
    
    private func profileImage(for user: User?) -> some View {
        Group {
            if let url = URL(string: user?.profileImage ?? ""), !(user?.profileImage ?? "").isEmpty {
                WebImage(url: url)
                    .placeholder {
                        Circle()
                            .fill(Color.paperBeige.opacity(0.5))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.brownLeather.opacity(0.7))
                                    .font(.title2)
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.antiqueGold.opacity(0.3), lineWidth: 2))
                    .shadow(color: .brownLeather.opacity(0.2), radius: 6, x: 0, y: 3)
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.paperBeige.opacity(0.8), Color.antiqueGold.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.brownLeather.opacity(0.7))
                            .font(.title2)
                    )
                    .shadow(color: .brownLeather.opacity(0.2), radius: 6, x: 0, y: 3)
            }
        }
    }
    
    // 스토리 컨텐츠 섹션
    private var storyContentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.brownLeather)
                
                Text("나의 생각")
                    .font(.scoreDream(.bold, size: .body))
                    .foregroundColor(.primaryText)
                
                Spacer()
            }
            
            Text(story.content ?? "")
                .font(.scoreDream(.regular, size: .body))
                .foregroundColor(.primaryText)
                .lineSpacing(6)
                .frame(minHeight: 60, alignment: .topLeading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // 책 정보
    private var bookInfoSection: some View {
        NavigationLink(destination: {
            BookDetailView(book: story.bookId)
                .environmentObject(storiesViewModel)
                .environmentObject(userViewModel)
        }) {
            HStack(spacing: 16) {
                WebImage(url: URL(string: story.bookId.bookImageURL))
                    .placeholder {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.paperBeige.opacity(0.3))
                            .overlay(
                                Image(systemName: "book.closed.fill")
                                    .foregroundColor(.brownLeather.opacity(0.7))
                                    .font(.title2)
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.antiqueGold.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .brownLeather.opacity(0.2), radius: 6, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(story.bookId.title)
                        .font(.scoreDream(.bold, size: .subheadline))
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(story.bookId.author.joined(separator: ", "))
                        .font(.scoreDream(.medium, size: .caption))
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                    
                    Text(story.bookId.publisher)
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.brownLeather.opacity(0.7))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.2),
                                        Color.clear,
                                        Color.antiqueGold.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
        }
        .buttonStyle(CardButtonStyle())
    }
    
    // 스토리 정보 (작성일, 잠금여부)
    private var storyInfoSection: some View {
        HStack {
            // 내 스토리에서만 공개/비공개 표시
            if isMyStory {
                HStack(spacing: 6) {
                    Image(systemName: story.isPublic ? "eye.fill" : "eye.slash.fill")
                        .font(.caption)
                        .foregroundColor(story.isPublic ? .brownLeather : .secondaryText)
                    
                    Text(story.isPublic ? "공개" : "비공개")
                        .font(.scoreDream(.medium, size: .caption))
                        .foregroundColor(story.isPublic ? .brownLeather : .secondaryText)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(story.isPublic ? Color.brownLeather.opacity(0.1) : Color.secondaryText.opacity(0.1))
                )
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(.secondaryText.opacity(0.7))
                
                Text("작성일: \(story.updatedAt.prefix(10))")
                    .font(.scoreDream(.light, size: .caption))
                    .foregroundColor(.secondaryText.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
    }
    
    // 댓글 버튼
    private var commentButton: some View {
        Button(action: {
            if userAuthManager.isUserAuthenticated {
                isExpanded.toggle()
            } else {
                alertType = .loginRequired
                showAlert = true
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.brownLeather)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("댓글")
                        .font(.scoreDream(.bold, size: .body))
                        .foregroundColor(.primaryText)
                    
                    Text("\(commentViewModel.totalCommentCount)개의 댓글")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondaryText.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.brownLeather.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 20)
        }
        .buttonStyle(CardButtonStyle())
    }
    
    // MARK: - NAVIGATION & ACTIONS
    
    private var navBarButton: some View {
        Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .font(.title3.weight(.medium))
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
