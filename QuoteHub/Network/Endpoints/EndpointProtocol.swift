//
//  EndpointProtocol.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import Foundation

/// 서버 주소를 한 곳에서 관리한다.
/// 빌드 구성에 따라 자동으로 갈리므로, 개발 중 URL을 손으로 바꿔가며 커밋할 일이 없다.
enum ServerEnvironment {
    /// 운영 서버 (커스텀 도메인 → Cloudflare Worker → Cloud Run).
    /// 이 주소는 고정이다. 백엔드를 옮길 땐 Cloudflare Worker의 ORIGIN만 바꾸면 되고
    /// 이 값은 건드리지 않는다 → 앱 재배포 불필요.
    static let production = "https://quotehub-api.iyungui.dev"

    /// 시뮬레이터에서 로컬 서버(`npm start`)에 붙을 때 사용.
    /// 실기기로 테스트하려면 맥의 LAN IP로 바꾼다. (예: http://192.168.0.10:3000)
    static let local = "http://localhost:3000"

    /// DEBUG 빌드에서 로컬 서버를 쓰려면 true로 변경.
    /// 기본값이 false이므로 평소 디버그 실행도 운영 서버를 바라본다.
    private static let useLocalServerInDebug = false

    static var baseURL: String {
        #if DEBUG
        return useLocalServerInDebug ? local : production
        #else
        return production
        #endif
    }
}

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
        ServerEnvironment.baseURL
    }
    
    var fullURL: String {
        return baseURL + path
    }
}
