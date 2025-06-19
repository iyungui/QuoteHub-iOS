//
//  LoadType.swift
//  QuoteHub
//
//  Created by 이융의 on 6/19/25.
//

import Foundation

// Sendable: A thread-safe type whose values can be shared across arbitrary concurrent contexts without introducing a risk of data races.
enum LoadType: Equatable, Hashable, Sendable {
    case my
    case friend(String) // friendID
    case `public`
}
