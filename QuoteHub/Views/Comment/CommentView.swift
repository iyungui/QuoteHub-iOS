//
//  CommentView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/13/23.
//

import SwiftUI

struct CommentView: View {
    @Environment(BookStoryCommentsViewModel.self) private var commentViewModel
    @Environment(UserViewModel.self) private var userViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var newComment: String = ""
    @State private var replyingTo: BookStoryComment?
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            commentListSection
            
            commentInputSection
        }
        .background(Color(.systemBackground))
        .task {
            // 댓글이 비어있을 때만 새로 로드
            if commentViewModel.comments.isEmpty {
                commentViewModel.refreshComments()
            }
        }
        .alert("오류", isPresented: .constant(commentViewModel.errorMessage != nil)) {
            Button("확인") {
                commentViewModel.errorMessage = nil
            }
        } message: {
            Text(commentViewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - HEADER SECTION
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            // 제목과 댓글 개수
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("댓글")
                        .font(.scoreDream(.bold, size: .title3))
                        .foregroundColor(.primaryText)
                    
                    Text("\(commentViewModel.commentCount)개")
                        .font(.scoreDream(.medium, size: .caption))
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                // 로딩 인디케이터
                if commentViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(20)
            
            Divider()
                .background(Color.secondary.opacity(0.2))
        }
    }
    
    // MARK: - COMMENT LIST SECTION
    
    private var commentListSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // 스크롤 맨 위로 이동을 위한 앵커
                    Color.clear
                        .frame(height: 1)
                        .id("top")
                    
                    if commentViewModel.comments.isEmpty && !commentViewModel.isLoading {
                        // 댓글이 없을 때 표시할 빈 화면
                        emptyCommentsView
                    } else {
                        // 댓글 목록
                        ForEach(commentViewModel.comments, id: \.id) { comment in
                            CommentRowView(
                                comment: comment,
                                onReply: { replyComment in
                                    replyingTo = replyComment
                                    isInputFocused = true
                                }
                            )
                            .task {
                                // 마지막 댓글에 도달하면 다음 댓글 로드 (무한 스크롤)
                                commentViewModel.loadMoreIfNeeded(currentItem: comment)
                            }
                            .id(comment.id)
                            
                            // 마지막 댓글이 아니면 구분선 추가
                            if comment.id != commentViewModel.comments.last?.id {
                                Divider()
                                    .background(Color.secondary.opacity(0.1))
                                    .padding(.leading, 80)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .onChange(of: commentViewModel.comments.count) { oldValue, newValue in
                // 새 댓글이 추가되면 자동으로 맨 위로 스크롤
                if newValue > oldValue {
                    withAnimation(.easeOut(duration: 0.5)) {
                        proxy.scrollTo("top", anchor: .top)
                    }
                }
            }
        }
    }
    
    // MARK: - EMPTY COMMENTS VIEW (댓글이 없을 때)
    private var emptyCommentsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("아직 댓글이 없습니다")
                .font(.scoreDream(.medium, size: .body))
                .foregroundColor(.secondaryText)
            
            Text("첫 댓글을 남겨보세요!")
                .font(.scoreDream(.regular, size: .subheadline))
                .foregroundColor(.secondaryText.opacity(0.8))
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - COMMENT INPUT SECTION
    private var commentInputSection: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.secondary.opacity(0.2))
            
            VStack(spacing: 12) {
                // 답글 인디케이터 (답글을 작성 중일 때만 표시)
                if let replyingTo = replyingTo {
                    replyIndicatorView(replyingTo)
                }
                
                // 댓글 입력 필드
                HStack(spacing: 12) {
                    // 현재 사용자 프로필 이미지
                    ProfileImage(
                        profileImageURL: userViewModel.currentUser?.profileImage ?? "",
                        size: 36
                    )
                    
                    HStack(spacing: 8) {
                        TextField(
                            replyingTo != nil ? "\(replyingTo!.userId.nickname)님에게 답글" : "댓글을 입력하세요",
                            text: $newComment,
                            axis: .vertical
                        )
                        .focused($isInputFocused)
                        .font(.scoreDream(.regular, size: .subheadline))
                        .lineLimit(1...4)
                        .submitLabel(.send)
                        .onSubmit {
                            Task { await submitComment() }
                        }
                        
                        // 전송 버튼 (텍스트가 입력되었을 때만 표시)
                        if !newComment.isEmpty {
                            Button {
                                Task { await submitComment() }
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.brownLeather)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - 답글 인디케이터 UI
    private func replyIndicatorView(_ comment: BookStoryComment) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "arrowshape.turn.up.left.fill")
                .font(.caption)
                .foregroundColor(.brownLeather)
            
            Text("\(comment.userId.nickname)님에게 답글")
                .font(.scoreDream(.medium, size: .caption))
                .foregroundColor(.brownLeather)
            
            Spacer()
            
            // 답글 취소 버튼
            Button {
                replyingTo = nil
                isInputFocused = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.brownLeather.opacity(0.1))
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - private action
    private func submitComment() async {
        // 빈 댓글은 전송하지 않음
        guard !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let content = newComment
        let parentId = replyingTo?.id
        
        // 입력 필드 초기화
        newComment = ""
        replyingTo = nil
        isInputFocused = false
        
        // 댓글 전송
        _ = await commentViewModel.addComment(
            content: content,
            parentCommentId: parentId
        )
        
        // 성공하면 자동으로 맨 위로 스크롤됨 (onChange에서 처리)
    }
}
