//
//  BookDataModel.swift
//  QuoteHub
// 
//  Created by 이융의 on 2023/09/09. 
//

import Foundation

struct RandomBooksResponse: Codable {
    let success: Bool
    let data: [Book]
}

struct BooksResponse: Codable {
    let documents: [Book]
    let meta: Meta
}

struct Book: Codable, Identifiable {
    var id: String { _id }
    let title: String?
    let author: [String]?
    let translator: [String]?
    let introduction: String?
    let publisher: String?
    let publicationDate: String?
    var publicationDatePrefix: String? {
        return publicationDate?.prefix(10).description
    }
    let bookImageURL: String?
    let bookLink: String?
    let ISBN: [String]?
    let _id: String
}

struct Meta: Codable {
    let is_end: Bool
    let pageable_count: Int
    let total_count: Int
}
