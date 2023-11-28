//
//  CommentView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/13/23.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - MY VIEW

struct CommentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var newComment: String = ""
    @ObservedObject var viewModel: CommentViewModel
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @FocusState private var isInputActive: Bool
    @StateObject var userViewModel = UserViewModel()

    var body: some View {
        VStack {
            commentInputSection
            commentListSection
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("오류"), message: Text(errorMessage), dismissButton: .default(Text("확인")))
        }
        .onAppear {
            userViewModel.getProfile(userId: nil)
        }
    }
    
    private var commentInputSection: some View {
        HStack(spacing: 15) {
            TextField("댓글 남기기", text: $newComment)
                .focused($isInputActive)
                .submitLabel(.done)
                .onSubmit {
                    if !newComment.isEmpty {
                        sendComment()
                    }
                }
                .font(.caption)
                .padding(10)
                .padding(.vertical, 5)
                .background(Color(.systemGray5))
                .cornerRadius(8)

            sendCommentButton
        }
        .padding()
    }
    
    private func sendComment() {
        viewModel.addCommentToStory(content: newComment, parentCommentId: nil) { result in
            switch result {
            case .success(_):
                newComment = ""
                isInputActive = false
            case .failure(let error):
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }

    private var sendCommentButton: some View {
        Button(action: {
            if !newComment.isEmpty {
                sendComment()
            }
        }) {
            Image(systemName: "paperplane.fill")
                .font(.title2)
                .foregroundColor(newComment.isEmpty ? Color.gray : colorScheme == .dark ? .white : .black)
                .disabled(newComment.isEmpty)
        }
        .buttonStyle(PlainButtonStyle())
    }


    
    private var commentListSection: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.bookStoryComments, id: \.id) { comment in
                    VStack(alignment: .leading, spacing: 10) {
                        commentRow(comment: comment).environmentObject(viewModel).environmentObject(userViewModel)
                        Divider()
                    }
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                if !viewModel.isLastPage {
                    ProgressView()
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentItem: viewModel.bookStoryComments.last)
                        }
                }
            }
        }
    }
}


struct commentRow: View {
    let comment: BookStoryComment
    @EnvironmentObject var viewModel: CommentViewModel
    @State private var commentShowingSheet: Bool = false
    @State private var showDeleteErrorAlert: Bool = false
    @State private var deleteErrorMessage: String = ""
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userViewModel: UserViewModel


    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                WebImage(url: URL(string: comment.userId.profileImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(comment.userId.nickname)
                        .font(.system(size: 14, weight: .semibold))
                    Text(comment.content)
                        .font(.system(size: 14))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .lineLimit(nil)
                }
                Spacer()
                if comment.userId.id == userViewModel.user?.id {
                    Button(action: {
                        print("commentShowingSheet")
                        commentShowingSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.callout)
                            .rotationEffect(Angle(degrees: 90))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .actionSheet(isPresented: $commentShowingSheet) {
            ActionSheet(title: Text("선택"), buttons: actionSheetButtons())
        }
        .alert(isPresented: $showDeleteErrorAlert) {
            Alert(title: Text("오류"), message: Text(deleteErrorMessage), dismissButton: .default(Text("확인")))
        }
    }
    private func actionSheetButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = [.cancel()]

        // Check if the current user is the author of the comment
        if comment.userId.id == userViewModel.user?.id ?? "" {
            let deleteButton = ActionSheet.Button.destructive(Text("댓글 삭제하기")) {
                viewModel.deleteCommentStory(commentId: comment.id) { success, errorMessage in
                    if !success {
                        deleteErrorMessage = errorMessage ?? "댓글을 삭제할 수 없습니다."
                        showDeleteErrorAlert = true
                    }
                }
            }
            buttons.insert(deleteButton, at: 0)
        }

        return buttons
    }
}
