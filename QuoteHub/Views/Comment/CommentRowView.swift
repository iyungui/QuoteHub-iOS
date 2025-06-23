//
//  CommentRowView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

// MARK: - COMMENT ROW VIEW

struct CommentRowView: View {
    let comment: BookStoryComment
    let onReply: (BookStoryComment) -> Void
    
    @Environment(BookStoryCommentsViewModel.self) private var commentViewModel
    @Environment(UserViewModel.self) private var userViewModel
    
    @State private var showActionSheet = false
    @State private var showEditSheet = false
    @State private var editedContent = ""
    
    // 현재 사용자의 댓글인지 확인
    var isMyComment: Bool {
        comment.userId.id == userViewModel.currentUser?.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // 프로필 이미지
                ProfileImage(
                    profileImageURL: comment.userId.profileImage,
                    size: 40
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    // 사용자 정보와 작성 시간
                    HStack(spacing: 8) {
                        Text(comment.userId.nickname)
                            .font(.scoreDream(.bold, size: .subheadline))
                            .foregroundColor(.primaryText)
                        
                        Text(timeAgoString(from: comment.updatedAt))
                            .font(.scoreDream(.light, size: .caption2))
                            .foregroundColor(.secondaryText.opacity(0.8))
                        
                        Spacer()
                        
                        // 내 댓글에만 메뉴 버튼 표시
                        if isMyComment {
                            Button {
                                showActionSheet = true
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                    .rotationEffect(.degrees(90))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // 댓글 내용
                    Text(comment.content)
                        .font(.scoreDream(.regular, size: .subheadline))
                        .foregroundColor(.primaryText.opacity(0.9))
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                    
                    // 답글 버튼 (루트 댓글에만 표시)
                    if comment.parentCommentId == nil {
                        Button {
                            onReply(comment)
                        } label: {
                            Text("답글")
                                .font(.scoreDream(.medium, size: .caption))
                                .foregroundColor(.brownLeather.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                }
                
                Spacer(minLength: 0)
            }
            
            // 대댓글 목록
            if let replies = comment.replies, !replies.isEmpty {
                VStack(spacing: 12) {
                    ForEach(replies, id: \.id) { reply in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "arrowshape.turn.up.left")
                                .font(.caption)
                                .foregroundColor(.secondary.opacity(0.6))
                                .padding(.top, 2)
                            
                            // 재귀적으로 댓글 뷰 호출
                            CommentRowView(comment: reply, onReply: onReply)
                        }
                        .padding(.leading, 16)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .confirmationDialog("댓글 옵션", isPresented: $showActionSheet) {
            Button("수정") {
                editedContent = comment.content
                showEditSheet = true
            }
            
            Button("삭제", role: .destructive) {
                Task {
                    await commentViewModel.deleteComment(commentId: comment.id)
                }
            }
            
            Button("취소", role: .cancel) { }
        }
        .sheet(isPresented: $showEditSheet) {
            CommentEditView(
                originalContent: comment.content,
                onSave: { newContent in
                    Task {
                        await commentViewModel.updateComment(
                            commentId: comment.id,
                            content: newContent
                        )
                    }
                }
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }
}
