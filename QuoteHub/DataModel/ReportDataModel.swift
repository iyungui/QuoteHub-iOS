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
    let targetId: User
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
        case User
        case BookStory
    }
}


struct StoryReportDataModel: Codable, Identifiable {
    var id: String { _id }
    let _id: String
    let targetId: BookStory
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
        case User
        case BookStory
    }
    
    struct BookStory: Codable {
        var _id: String
        var userId: String
        var bookId: String
        var quote: String?
        var content: String?
        var storyImageURLs: [String]?
        var isPublic: Bool
        var createdAt: String
        var updatedAt: String
        var keywords: [String]?
        var folderIds: [String]?
    }
}
