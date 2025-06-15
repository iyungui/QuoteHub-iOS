//
//  EndpointProtocol.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

protocol EndpointProtocol {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var requiresAuth: Bool { get }
    var fullURL: String { get }
}

extension EndpointProtocol {
    var baseURL: String {
        "https://port-0-quotehub-server-m015aiy374b6cd11.sel4.cloudtype.app"
    }
    
    var fullURL: String {
        return baseURL + path
    }
}
