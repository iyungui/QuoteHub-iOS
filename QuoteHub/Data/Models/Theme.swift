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
    var description: String
    var folderImageURL: String
    var isPublic: Bool

    var createdAt: String
    var updatedAt: String

    var createdAtDate: String {
        return String(createdAt.prefix(10))
    }
    var updatedAtDate: String {
        return String(updatedAt.prefix(10))
    }
    
    static func ==(lhs: Theme, rhs: Theme) -> Bool {
        return lhs.id == rhs.id
    }
}
