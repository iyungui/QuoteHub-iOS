//
//  Report.swift
//  QuoteHub
//
//  Created by 이융의 on 11/25/23.
//

import Foundation

struct Report: Codable, Identifiable {
    var id: String { _id }
    let _id: String
    let targetId: String
    let reporterId: User
    let type: ReportType
    let reason: String
    let onModel: ModelType
    let createdAt: String?
    let updatedAt: String?
    
    enum ReportType: String, Codable {
        case user
        case bookstory
    }

    enum ModelType: String, Codable {
        case User
        case BookStory
    }
}
