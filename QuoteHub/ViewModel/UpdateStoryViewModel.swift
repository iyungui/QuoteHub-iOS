////
////  UpdateStoryViewModel.swift
////  QuoteHub
////
////  Created by 이융의 on 11/18/23.
////
//
//import Foundation
//import SwiftUI
//import SDWebImageSwiftUI
//
//class UpdateStoryViewModel: ObservableObject {
//    @Published var keywords: [String] = []
//    @Published var selectedImages: [UIImage] = []
//    @Published var quote: String = ""
//    @Published var content: String = ""
//    @Published var isPublic: Bool = true
//    @Published var folderIds: [String] = []
//    @Published var bookImage: String = ""
//    @Published var bookTitle: String = "제목 없음"
//    @Published var bookAuthor: [String] = ["저자 미상"]
//    @Published var bookPublisher: String = "출판사 정보 없음"
//
//    var storyId: String
//
//    init(storyId: String) {
//        self.storyId = storyId
//    }
//
//    func loadStoryData(from myStoriesViewModel: BookStoriesViewModel) {
//        if let story = myStoriesViewModel.bookStories.first(where: { $0.id == storyId }) {
//            // 스토리 데이터로 변수들을 초기화
//            keywords = story.keywords ?? []
//            quote = story.quote ?? ""
//            content = story.content ?? ""
//            isPublic = story.isPublic
//            folderIds = story.folderIds ?? []
//            bookImage = story.bookId.bookImageURL
//            bookTitle = story.bookId.title
//            bookAuthor = story.bookId.author
//            bookPublisher = story.bookId.publisher
//            story.storyImageURLs?.forEach { imageURLString in
//                if let imageURL = URL(string: imageURLString) {
//                    SDWebImageDownloader.shared.downloadImage(with: imageURL) { image, _, _, _ in
//                        DispatchQueue.main.async {
//                            if let image = image {
//                                self.selectedImages.append(image)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
