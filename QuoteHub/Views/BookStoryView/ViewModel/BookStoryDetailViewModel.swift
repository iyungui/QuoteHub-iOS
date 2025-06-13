//
//  BookStoryDetailViewModel.swift
//  QuoteHub
//
//  Created by AI Assistant on 6/12/25.
//

import SwiftUI

class BookStoryDetailViewModel: ObservableObject, LoadingViewModel {
    @Published var story: BookStory?
    @Published var loadedImages: [UIImage] = []

    @Published var isLoading: Bool = false
    @Published var loadingMessage: String? = ""
    @Published var errorMessage: String?
    
    /// true: 캐러셀뷰, false: 리스트뷰
    @Published var isCarouselView: Bool = false
    // 댓글창 on off
    @Published var isCommentSheetExpanded: Bool = false
    // 북스토리 수정 (그리고 차단) 위한 액션시트
    @Published var showActionSheet: Bool = false

    // 알림 관련
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let storiesViewModel: BookStoriesViewModel
    
    init(storiesViewModel: BookStoriesViewModel) {
        self.storiesViewModel = storiesViewModel
    }
    
    // MARK: - Methods
    /// 북스토리 id를 통해 서버로부터 해당 최신 북스토리 받아오는 함수
    func loadStoryDetail(storyId: String) {
        isLoading = true
        loadingMessage = "북스토리를 불러오는 중..."
        errorMessage = nil
        storiesViewModel.fetchSpecificBookStory(storyId: storyId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let story):
                    self.isLoading = false
                    self.story = story
                    self.loadImagesFromStory(story)
                case .failure(let error):
                    self.isLoading = false

                    self.errorMessage = error.localizedDescription
                    self.alertMessage = "북스토리를 불러오지 못했어요."
                    self.showAlert = true
                }
            }
        }
    }
    
    /// 북스토리를 로드할 때, 이미지 url 들을 UIImage로 변환하는 함수
    private func loadImagesFromStory(_ story: BookStory) {
        guard let imagesURLs = story.storyImageURLs, !imagesURLs.isEmpty else {
            loadedImages = []
            return
        }
        
        var tempImages: [UIImage] = []
        let group = DispatchGroup()
        
        for urlString in imagesURLs {
            group.enter()
            
            guard let url = URL(string: urlString) else {
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }
                
                guard let data = data,
                      let image = UIImage(data: data) else {
                    print("북스토리 이미지를 불러오지 못했습니다. \(urlString)")
                    return
                }
                
                DispatchQueue.main.async {
                    tempImages.append(image)
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            self.loadedImages = tempImages
        }
    }
}
