////
////  ReportViewModel.swift
////  QuoteHub
////
////  Created by 이융의 on 11/25/23.
////
//
//import Foundation
//
//class ReportViewModel: ObservableObject {
//    @Published var reportedUsers: [ReportDataModel] = []
//    @Published var reportedStories: [StoryReportDataModel] = []
//
//    private var reportService = ReportService()
//
//    // 사용자 신고 함수
//    func reportUser(targetId: String, reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        reportService.reportUser(targetId: targetId, reason: reason) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    print("User reported successfully")
//                    completion(.success(()))
//                case .failure(let error):
//                    print("Error reporting user: \(error)")
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//
//    // 게시물 신고 함수
//    func reportBookStory(targetId: String, reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
//        reportService.reportBookStory(targetId: targetId, reason: reason) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    print("Book story reported successfully")
//                    completion(.success(()))
//                case .failure(let error):
//                    print("Error reporting book story: \(error)")
//                    completion(.failure(error))
//                }
//            }
//        }
//    }
//
//    // 사용자 신고 목록을 가져오는 함수
//    func getReportedUsers() {
//        reportService.getReportUsers { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let reports):
//                    print("사용자 신고 목록 가져오기 성공")
//                    self?.reportedUsers = reports
//                case .failure(let error):
//                    print("사용자 신고 목록 가져오기 실패: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    // 게시물 신고 목록을 가져오는 함수
//    func getReportedStories() {
//        reportService.getReportStories { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let reports):
//                    print("게시물 신고 목록 가져오기 성공")
//                    self?.reportedStories = reports
//                case .failure(let error):
//                    print("게시물 신고 목록 가져오기 실패: \(error)")
//                }
//            }
//        }
//    }
//}
