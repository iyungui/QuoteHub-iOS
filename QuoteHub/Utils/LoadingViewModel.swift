//
//  LoadingViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 6/18/25.
//

import Foundation

@MainActor
protocol LoadingViewModel: ObservableObject {
    var isLoading: Bool { get }
    var loadingMessage: String? { get }
}
