//
//  BookStoryDetailViewModel.swift
//  QuoteHub
//
//  Created by AI Assistant on 6/12/25.
//

import SwiftUI

@MainActor
@Observable
final class BookStoryDetailViewModel: LoadingViewModel {
    // MARK: - Init && Properties
    
    // LoadingViewModel Protocol
    var isLoading: Bool = false
    var loadingMessage: String? = ""
    
    // Published Properties
    var story: BookStory?
    var loadedImages: [UIImage] = []
    var errorMessage: String?
    
    /// true: 캐러셀뷰, false: 리스트뷰
    var isCarouselView: Bool = false
    // 댓글창 on off
    var isCommentSheetExpanded: Bool = false
    // 북스토리 수정 (그리고 차단) 위한 액션시트
    var showActionSheet: Bool = false
    var showReportSheet: Bool = false
    
    // 알림 관련
    var showAlert: Bool = false
    var alertMessage: String = ""
    
    // Task Management
    private var loadingTask: Task<Void, Never>?
    private var imageLoadingTask: Task<Void, Never>?
    
    // 여기서 BookStoriesViewModel을 주입받음(의존)
    private let storiesViewModel: BookStoriesViewModel
    
    init(storiesViewModel: BookStoriesViewModel) {
        self.storiesViewModel = storiesViewModel
    }
    
    // MARK: - Public Methods
    
    /// 북스토리 id를 통해 서버로부터 해당 최신 북스토리 받아오는 메서드
    func loadStoryDetail(storyId: String) {
        cancelLoadingTask()
        
        loadingTask = Task {
            await performLoadStoryDetail(storyId: storyId)
        }
    }
    
    /// 뷰 방식 토글 (캐러셀 <-> 리스트)
    func toggleViewMode() {
        isCarouselView.toggle()
    }
    
    /// 댓글 시트 토글
    func toggleCommentSheet() {
        isCommentSheetExpanded.toggle()
    }
    /// 신고 시트 토글
    func toggleReportSheet() {
        showReportSheet.toggle()
    }

    /// 액션 시트 표시
    func showActionSheetView() {
        showActionSheet = true
    }
    
    /// 알림 표시
    func showAlertWith(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    /// 모든 Task 취소
    func cancelAllTasks() {
        loadingTask?.cancel()
        imageLoadingTask?.cancel()
        loadingTask = nil
        imageLoadingTask = nil
    }
}

private extension BookStoryDetailViewModel {
    
    /// story detail view load execution
    func performLoadStoryDetail(storyId: String) async {
        isLoading = true
        loadingMessage = "북스토리를 불러오는 중..."
        clearErrorMessage()
        
        defer {
            isLoading = false
            loadingMessage = nil
        }
        
        do {
            // Task 취소 확인
            try Task.checkCancellation()
            
            // BookStoriesViewModel을 통해 스토리 fetch
            let fetchedStory = await storiesViewModel.fetchSpecificBookStory(storyId: storyId)
            
            try Task.checkCancellation()
            
            guard let fetchedStory = fetchedStory else {
                errorMessage = "북스토리를 찾을 수 없습니다."
                alertMessage = "북스토리를 불러오지 못했어요."
                showAlert = true
                return
            }
            
            // 스토리 업데이트
            story = fetchedStory
            
            // 이미지 로드 시작
            await loadImagesFromStory(fetchedStory)
            
        } catch is CancellationError {
            // Task가 취소된 경우 - 아무것도 하지 않고 리턴
            return
        } catch {
            print("북스토리 로드 실패: \(error)")
            handleError(error)
            alertMessage = "북스토리를 불러오지 못했어요."
            showAlert = true
        }
    }
    
    /// 북스토리를 로드하고, 이미지 url 들을 UIImage로 병렬로 변환하는 메서드
    func loadImagesFromStory(_ story: BookStory) async {
        // 이미지 옵셔널, 공백 처리
        guard let imageURLs = story.storyImageURLs, !imageURLs.isEmpty else {
            loadedImages = []
            return
        }
        print("이미지 배열: \(imageURLs)")
        // 기존 이미지 로딩 Task 취소
        imageLoadingTask?.cancel()
        
        imageLoadingTask = Task { @MainActor in
            await performLoadImages(from: imageURLs)
        }
        
        await imageLoadingTask?.value
    }
    
    
    /// 이미지를 병렬로 로드하되 순서 보장
    private func performLoadImages(from imageURLs: [String]) async {
        do {
            // Task 취소 확인
            try Task.checkCancellation()
            
            // TaskGroup으로 이미지 로드 병렬 처리
            let images = await withTaskGroup(of: (index: Int, image: UIImage?).self, returning: [UIImage].self) { group in
                
                // 각 이미지 URL에 대해 Task 생성 (인덱스와 함께)
                for (index, urlString) in imageURLs.enumerated() {
                    group.addTask {
                        let image = await self.loadSingleImage(from: urlString)
                        return (index: index, image: image)
                    }
                }
                
                // 결과를 순서대로 정렬하여 반환
                var indexedImages: [(index: Int, image: UIImage?)] = []
                for await result in group {
                    indexedImages.append(result)
                }
                
                // 인덱스 순서로 정렬하고 성공한 이미지만 추출
                return indexedImages
                    .sorted { $0.index < $1.index }
                    .compactMap { $0.image }
            }
            // Task 취소 확인
            try Task.checkCancellation()
            
            // 메인 스레드에서 이미지 배열 업데이트
            loadedImages = images
            
        } catch is CancellationError {
            // Task가 취소된 경우 - 아무것도 하지 않고 리턴
            return
        } catch {
            print("이미지 로드 실패: \(error)")
            loadedImages = []
        }
    }
    
    /// 단일 이미지를 로드하는 함수
    func loadSingleImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("유효하지 않은 URL: \(urlString)")
            return nil
        }
        
        do {
            // Task 취소 확인
            try Task.checkCancellation()
            
            // URLSession의 async 메서드 사용
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Task 취소 확인
            try Task.checkCancellation()
            
            // HTTP 응답 상태 확인
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                print("HTTP 에러 \(httpResponse.statusCode) for URL: \(urlString)")
                return nil
            }
            
            // 이미지 데이터를 UIImage로 변환
            guard let image = UIImage(data: data) else {
                print("이미지 데이터 변환 실패: \(urlString)")
                return nil
            }
            
            return image
            
        } catch is CancellationError {
            // Task가 취소된 경우
            return nil
        } catch {
            print("이미지 로드 에러 \(urlString): \(error)")
            return nil
        }
    }
    
    /// 로딩 Task 취소
    func cancelLoadingTask() {
        loadingTask?.cancel()
        loadingTask = nil
    }
    
    /// 에러 메시지 초기화
    func clearErrorMessage() {
        errorMessage = nil
    }
    
    /// 에러 처리
    func handleError(_ error: Error) {
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = "알 수 없는 오류가 발생했습니다.: \(error.localizedDescription)"
        }
    }
}
