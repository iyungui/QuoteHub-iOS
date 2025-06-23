//
//  Theme.swift
//  QuoteHub
//
//  Created by 이융의 on 10/30/23.
//

import Foundation

struct Theme: Codable, Identifiable, Equatable {
    var id: String { _id }
    var _id: String
    var userId: User
    
    var name: String
    var description: String?
    var themeImageURL: String?
    var isPublic: Bool

    var createdAt: String
    var updatedAt: String

    static func ==(lhs: Theme, rhs: Theme) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case _id
        case userId
        case name
        case description
        case themeImageURL = "folderImageURL"
        case isPublic
        case createdAt
        case updatedAt
    }
}
