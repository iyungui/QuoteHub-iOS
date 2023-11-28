//
//  ReportDataModel.swift
//  QuoteHub
//
//  Created by 이융의 on 11/25/23.
//

import Foundation

struct ReportDataModel: Codable, Identifiable {
    var id: String { _id }
    let _id: String
    let targetId: Target
    let reporterId: String
    let type: ReportType
    let reason: String
    let status: ReportStatus
    let onModel: OnModelType

    enum ReportType: String, Codable {
        case user
        case bookstory
    }

    enum ReportStatus: String, Codable {
        case pending
        case reviewed
        case resolved
    }

    enum OnModelType: String, Codable {
        case User = "User"
        case BookStory = "BookStory"
    }

    enum Target: Codable {
        case user(User)
        case bookStory(BookStory)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(String.self, forKey: ._id)
        reporterId = try container.decode(String.self, forKey: .reporterId)
        type = try container.decode(ReportType.self, forKey: .type)
        reason = try container.decode(String.self, forKey: .reason)
        status = try container.decode(ReportStatus.self, forKey: .status)
        onModel = try container.decode(OnModelType.self, forKey: .onModel)

        switch onModel {
        case .User:
            let user = try User(from: decoder)
            targetId = .user(user)
        case .BookStory:
            let bookStory = try BookStory(from: decoder)
            targetId = .bookStory(bookStory)
        }
    }
    
    var targetDisplayName: String {
        switch targetId {
        case .user(let user):
            return user.nickname // Assuming 'name' is a property of User
        case .bookStory(let bookStory):
            return bookStory.quote ?? "" // Assuming 'title' is a property of BookStory
        }
    }
}
