//
//  Book.swift
//  QuoteHub
// 
//  Created by 이융의 on 2023/09/09. 
//

import Foundation

struct Book: Codable, Identifiable {
    var id: String { _id }
    let title: String
    let author: [String]
    let translator: [String]
    let introduction: String
    let publisher: String
    let publicationDate: String
    var publicationDatePrefix: String {
        return publicationDate.prefix(10).description
    }
    let bookImageURL: String
    let bookLink: String
    let ISBN: [String]
    let _id: String
}

extension Book {
    // for preview
    static let previewBook: Book = Book(
        title: "코스모스",
        author: ["칼 세이건"],
        translator: [""],
        introduction: "",
        publisher: "",
        publicationDate: "",
        bookImageURL: "",
        bookLink: "",
        ISBN: [""],
        _id: ""
    )
}
