//
//  BookStoryCommentsViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import Foundation

@MainActor
@Observable
final class BookStoryCommentsViewModel: LoadingViewModelProtocol {
    
    // MARK: - LoadingViewModel 프로토콜 구현
    var isLoading = false
    var loadingMessage: String?
    
    // MARK: - 공개 프로퍼티
    var comments: [BookStoryComment] = []          // 댓글 목록
    var commentCount: Int = 0                      // 총 댓글 개수
    var isLastPage = false                         // 마지막 페이지 여부 (무한 스크롤용)
    var errorMessage: String?                      // 에러 메시지
    
    // MARK: - 비공개 프로퍼티
    private let bookStoryId: String                // 북스토리 ID
    private var currentPage = 1                    // 현재 페이지
    private let pageSize = 10                      // 페이지당 댓글 수
    private let service: BookStoryCommentServiceProtocol  // 서비스 의존성
    
    // MARK: - 작업 관리 (동시성 제어)
    private var loadingTask: Task<Void, Never>?                    // 댓글 로딩 작업
    private var countLoadingTask: Task<Void, Never>?               // 댓글 개수 로딩 작업
    private var operationTasks: Set<Task<BookStoryComment?, Never>> = []  // 생성/수정 작업들
    private var deletionTask: Task<Bool, Never>?                   // 삭제 작업
    
    // MARK: - 초기화
    init(bookStoryId: String, service: BookStoryCommentServiceProtocol = BookStoryCommentService.shared) {
        self.bookStoryId = bookStoryId
        self.service = service
    }
    
    // MARK: - 공개 메서드
    
    /// 댓글 새로고침 (처음부터 다시 로드)
    func refreshComments() {
        // 기존 로딩 작업 취소
        cancelLoadingTask()
        
        // 페이지네이션 상태 초기화
        currentPage = 1
        isLastPage = false
        
        // 댓글 데이터 초기화
        comments = []
        
        // 댓글 로드 시작
        loadComments()
        
        // 댓글 개수도 함께 로드
        loadCommentCount()
    }
    
    // MARK: - 댓글 로드
    
    /// 댓글 목록 로드 (페이지네이션 지원)
    func loadComments() {
        // 이미 로딩 중이거나 마지막 페이지면 중단
        guard loadingTask == nil else { return }
        guard !isLastPage else { return }
        
        // 새로운 로딩 작업 생성 및 시작
        loadingTask = Task { @MainActor in
            await performLoadComments()
        }
    }
    
    /// 실제 댓글 로드 작업 수행
    private func performLoadComments() async {
        isLoading = true
        loadingMessage = "댓글을 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
            loadingTask = nil
        }
        
        do {
            let response = try await service.getCommentsForStory(
                bookStoryId: bookStoryId,
                page: currentPage,
                pageSize: pageSize
            )
            
            // 작업이 취소되었는지 확인
            try Task.checkCancellation()
            
            // 새로운 댓글들을 기존 목록에 추가 (서버에서 최신순으로 정렬되어 옴)
            // Page 1: 최신 댓글들 (맨 위)
            // Page 2+: 더 오래된 댓글들 (기존 댓글 아래에 추가)
            comments.append(contentsOf: response.data)
            
            // 페이지네이션 상태 업데이트
            isLastPage = response.pagination.currentPage >= response.pagination.totalPages
            if !isLastPage {
                currentPage += 1
            }
            
        } catch is CancellationError {
            return
        } catch {
            print("댓글 로드 실패: storyId: \(bookStoryId), error: \(error)")
            handleError(error)
        }
    }
    
    /// 무한 스크롤을 위한 추가 로드 확인
    func loadMoreIfNeeded(currentItem item: BookStoryComment?) {
        guard let item = item else { return }
        
        // 현재 아이템이 배열의 마지막 아이템과 같으면 다음 페이지 로드
        if item == comments.last {
            loadComments()
        }
    }
    
    // MARK: - 댓글 개수 로드
    
    /// 총 댓글 개수 로드
    func loadCommentCount() {
        // 이미 로딩 중이면 중단
        guard countLoadingTask == nil else { return }
        
        countLoadingTask = Task { @MainActor in
            await performLoadCommentCount()
        }
    }
    
    /// 실제 댓글 개수 로드 작업 수행
    private func performLoadCommentCount() async {
        defer {
            countLoadingTask = nil
        }
        
        do {
            let response = try await service.getCommentCountForStory(bookStoryId: bookStoryId)
            
            try Task.checkCancellation()
            
            if response.success, let count = response.data {
                commentCount = count
            }
            
        } catch is CancellationError {
            return
        } catch {
            print("댓글 개수 로드 실패: storyId: \(bookStoryId), error: \(error)")
            // 댓글 개수는 중요하지 않으므로 에러를 사용자에게 표시하지 않음
        }
    }
    
    // MARK: - 댓글 추가
    
    /// 새 댓글 추가 (루트 댓글 또는 대댓글)
    func addComment(
        content: String,
        parentCommentId: String? = nil
    ) async -> BookStoryComment? {
        let task = Task { @MainActor in
            await performAddComment(
                content: content,
                parentCommentId: parentCommentId
            )
        }
        
        operationTasks.insert(task)
        let result = await task.value
        operationTasks.remove(task)
        
        return result
    }
    
    /// 실제 댓글 추가 작업 수행
    private func performAddComment(
        content: String,
        parentCommentId: String?
    ) async -> BookStoryComment? {
        isLoading = true
        loadingMessage = "댓글을 등록하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.addComment(
                bookStoryId: bookStoryId,
                content: content,
                parentCommentId: parentCommentId
            )
            
            try Task.checkCancellation()
            
            guard response.success, let newComment = response.data else {
                errorMessage = response.message
                return nil
            }
            
            // 새 댓글을 로컬 데이터에 추가
            addCommentToLocal(newComment)
            
            return newComment
            
        } catch is CancellationError {
            return nil
        } catch {
            print("댓글 생성 실패 - \(error.localizedDescription)")
            handleError(error)
            return nil
        }
    }
    
    // MARK: - 댓글 수정
    
    /// 댓글 내용 수정
    func updateComment(
        commentId: String,
        content: String
    ) async -> BookStoryComment? {
        let task = Task { @MainActor in
            await performUpdateComment(
                commentId: commentId,
                content: content
            )
        }
        
        operationTasks.insert(task)
        let result = await task.value
        operationTasks.remove(task)
        
        return result
    }
    
    /// 실제 댓글 수정 작업 수행
    private func performUpdateComment(
        commentId: String,
        content: String
    ) async -> BookStoryComment? {
        isLoading = true
        loadingMessage = "댓글을 수정하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            let response = try await service.updateComment(
                commentId: commentId,
                content: content
            )
            
            try Task.checkCancellation()
            
            guard let updatedComment = response.data else {
                errorMessage = "댓글 수정에 실패했습니다."
                return nil
            }
            
            // 로컬 데이터에서 댓글 업데이트
            updateCommentInLocal(updatedComment)
            
            return updatedComment
            
        } catch is CancellationError {
            return nil
        } catch {
            print("댓글 업데이트 실패: \(error.localizedDescription)")
            handleError(error)
            return nil
        }
    }
    
    // MARK: - 댓글 삭제
    
    /// 댓글 삭제
    func deleteComment(commentId: String) async -> Bool {
        deletionTask = Task { @MainActor in
            await performDeleteComment(commentId: commentId)
        }
        
        let result = await (deletionTask?.value ?? false)
        return result
    }
    
    /// 실제 댓글 삭제 작업 수행
    private func performDeleteComment(commentId: String) async -> Bool {
        isLoading = true
        loadingMessage = "댓글을 삭제하는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            _ = try await service.deleteComment(commentId: commentId)
            
            try Task.checkCancellation()
            
            // 로컬 데이터에서 댓글 삭제
            removeCommentFromLocal(commentId: commentId)
            
            return true
            
        } catch is CancellationError {
            return false
        } catch {
            handleError(error)
            return false
        }
    }
}

// MARK: - 비공개 헬퍼 메서드
private extension BookStoryCommentsViewModel {
    
    /// 새 댓글을 로컬 데이터에 추가 (루트 댓글 vs 대댓글 구분)
    func addCommentToLocal(_ comment: BookStoryComment) {
        if let parentCommentId = comment.parentCommentId {
            // 대댓글인 경우: 부모 댓글의 replies 배열에 추가
            addReplyToParentComment(reply: comment, parentId: parentCommentId)
        } else {
            // 루트 댓글인 경우: 최상단에 추가 (최신 댓글이 위로)
            comments.insert(comment, at: 0)
        }
        commentCount += 1
    }
    
    /// 대댓글을 부모 댓글의 replies 배열에 추가
    func addReplyToParentComment(reply: BookStoryComment, parentId: String) {
        // 부모 댓글을 찾아서 replies 배열에 추가
        for i in 0..<comments.count {
            if comments[i].id == parentId {
                var updatedComment = comments[i]
                if updatedComment.replies == nil {
                    updatedComment.replies = []
                }
                // 대댓글은 시간순으로 추가 (서버의 replies 정렬과 동일)
                updatedComment.replies?.append(reply)
                comments[i] = updatedComment
                break
            }
        }
    }
    
    /// 댓글을 로컬 데이터에서 업데이트 (루트 댓글 + 대댓글 모두 처리, replies 정보 보존)
    func updateCommentInLocal(_ comment: BookStoryComment) {
        // 1. 먼저 루트 댓글에서 찾기
        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            let existingComment = comments[index]
            
            // 기존 replies 정보 보존 (서버 응답에 replies가 없을 수 있음)
            var updatedComment = comment
            if updatedComment.replies == nil && existingComment.replies != nil {
                updatedComment.replies = existingComment.replies
            }
            
            comments[index] = updatedComment
            return
        }
        
        // 2. 루트 댓글에서 찾지 못하면 각 댓글의 replies 배열에서 찾기
        for i in 0..<comments.count {
            if var replies = comments[i].replies {
                if let replyIndex = replies.firstIndex(where: { $0.id == comment.id }) {
                    // 대댓글을 찾았으면 업데이트 (대댓글은 replies가 없으므로 그대로 교체)
                    replies[replyIndex] = comment
                    
                    // 부모 댓글의 replies 배열 업데이트
                    var updatedParentComment = comments[i]
                    updatedParentComment.replies = replies
                    comments[i] = updatedParentComment
                    
                    return
                }
            }
        }
    }
    
    /// 댓글을 로컬 데이터에서 삭제 (루트 댓글 + 대댓글 모두 처리)
    func removeCommentFromLocal(commentId: String) {
        // 1. 먼저 루트 댓글에서 찾아서 삭제
        let originalCount = comments.count
        comments.removeAll { $0.id == commentId }
        
        if comments.count < originalCount {
            // 루트 댓글을 삭제했으면
            commentCount = max(0, commentCount - 1)
            return
        }
        
        // 2. 루트 댓글에서 찾지 못하면 각 댓글의 replies 배열에서 찾아서 삭제
        for i in 0..<comments.count {
            if var replies = comments[i].replies {
                let originalReplyCount = replies.count
                replies.removeAll { $0.id == commentId }
                
                if replies.count < originalReplyCount {
                    // 대댓글을 삭제했으면
                    var updatedParentComment = comments[i]
                    updatedParentComment.replies = replies.isEmpty ? nil : replies
                    comments[i] = updatedParentComment
                    
                    commentCount = max(0, commentCount - 1)
                    return
                }
            }
        }
    }
    
    /// 로딩 작업 취소
    func cancelLoadingTask() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    /// 에러 메시지 초기화
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    /// 에러 처리 및 사용자 친화적 메시지 생성
    func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다: \(error.localizedDescription)"
        }
    }
}
