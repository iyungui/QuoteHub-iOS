//
//  NetworkError.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import Foundation
import Alamofire

enum NetworkError: Error, LocalizedError {
    case unauthorized
    case conflict(String?)
    case validationError(String?)
    case noInternetConnection
    case serverError
    case decodingError
    case unknown(String?)
}
