////
////  BookMarkDataModel.swift
////  QuoteHub
////
////  Created by 이융의 on 10/30/23.
////
//
//import Foundation
//
//struct BookMark: Codable, Identifiable, Equatable {
//    var id: String { _id }
//    var _id: String
//    var userId: String
//    var bookStoryId: BookStory
//    
//    static func ==(lhs: BookMark, rhs: BookMark) -> Bool {
//        return lhs.id == rhs.id
//    }
//    
//    var createdAt: String
//    var updatedAt: String
//    var createdAtDate: String {
//        return String(createdAt.prefix(10))
//    }
//    var updatedAtDate: String {
//        return String(updatedAt.prefix(10))
//    }
//
//}
//
//struct BookMarkResponse: Codable {
//    var success: Bool
//    var data: BookMark
//    var message: String?
//}
//
//struct BookMarkListResponse: Codable {
//    var success: Bool
//    var data: [BookMark]
//    var currentPage: Int
//    var totalPages: Int
//    var pageSize: Int
//    var totalItems: Int
//    let message: String?
//}
