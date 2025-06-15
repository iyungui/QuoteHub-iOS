//
//  APIClient.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import Foundation

final class APIClient {
    // 싱글톤패턴으로, 앱 전체에서 하나의 APIClient 인스턴스만 사용하도록 설정
    // URLSession 일관적으로 앱 전체에서 재사용
    static let shared = APIClient()
    
    private let session: URLSession
    private let tokenManager: KeyChainTokenManager
    
    // 싱글톤 패턴 강제 (오직 shared를 통해서만 접근하도록 설정)
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: config)
        self.tokenManager = KeyChainTokenManager()
    }
    
    /// 제네릭 요청 async throws 메서드
    func request<T: Codable, U: Codable>(
        endpoint: EndpointProtocol,
        body: T? = nil,
        responseType: U.Type,
        customHeaders: [String: String]? = nil,
        isRetry: Bool = false
    ) async throws -> U {
        
        // URL 생성
        guard let url = URL(string: endpoint.fullURL) else {
            throw NetworkError.invalidURL
        }
        
        // URLRequest 생성
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 필요 시 인증 헤더 추가
        if endpoint.requiresAuth {
            guard let accessToken = tokenManager.getAccessToken() else {
                // 액세스 토큰 읽기 실패 시
                throw NetworkError.unauthorized
            }
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // 필요 시 커스텀 헤더 추가
        customHeaders?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Body 추가 (T가 EmptyBody가 아닌 경우에만)
        if let body = body, !(body is EmptyData){
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.decodingError(error)
            }
        }
        
        // 네트워크 요청 실행
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // 상태 코드별 처리
            switch httpResponse.statusCode {
            case 200...299:
                return try parseSuccessResponse(data, responseType: responseType)
                
            case 401:
                // 인증 실패 - 토큰 리프레시 시도(재시도가 아닌 경우에만)
                if endpoint.requiresAuth && !isRetry {
                    let refreshSuccess = try await refreshTokenIfNeeded()
                    
                    // 리프레시 토큰 성공 시 재시도
                    if refreshSuccess {
                        return try await request(
                            endpoint: endpoint,
                            body: body,
                            responseType: responseType,
                            customHeaders: customHeaders,
                            isRetry: true   // isRetry를 true로 설정 (다음 request에는 재시도안함)
                        )
                    }
                }
                
                // 다시 401일 때 throw
                throw NetworkError.unauthorized
                
            default:
                let errorMessage = parseErrorResponse(data)
                throw NetworkError.serverError(httpResponse.statusCode, errorMessage)
            }
            
        } catch {
            if error is NetworkError { throw error }
            else { throw NetworkError.networkError(error) }
        }
    }
    
    /// 응답 파싱
    private func parseSuccessResponse<T: Codable>(_ data: Data, responseType: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    private func parseErrorResponse(_ data: Data) -> String {
        do {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            return errorResponse.message
        } catch {
            return "알 수 없는 서버 오류가 발생했습니다."
        }
    }

    /// 토큰 리프레시
    private func refreshTokenIfNeeded() async throws -> Bool {
        guard let refreshToken = tokenManager.getRefreshToken() else {
            // 리프레시 토큰이 nil이면 false
            return false
        }
        
        // 리프레시 토큰으로 새 액세스 토큰 요청하기
        let headers = ["Authorization": "Bearer \(refreshToken)"]
        
        do {
            let response: APIResponse<RenewTokenResponse> = try await request(
                endpoint: AuthEndpoints.renewToken,
                body: EmptyData(),
                responseType: APIResponse<RenewTokenResponse>.self,
                customHeaders: headers
            )
            
            guard let newAccessToken = response.data?.accessToken else {
                return false
            }
            
            // keychain에 토큰 업데이트 저장
            try tokenManager.updateAccessToken(newAccessToken)
            return true
        } catch {
            print("토큰 리프레시 실패: \(error)")
            return false
        }
    }
    
    // MARK: - Public Utility Methods
    
    /// 현재 유효한 액세스 토큰 반환
    func getValidAccessToken() -> String? {
        return tokenManager.getAccessToken()
    }
    
    /// 토큰 존재 여부 확인
    func hasValidToken() -> Bool {
        return tokenManager.hasValidToken()
    }
}
