//
//  APIClient.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import SwiftUI

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
    
    /// APIResponseProtocol타입-요청 async throws 메서드 (request, url, 헤더, body 설정만)
    func request<T: Codable, U: APIResponseProtocol & Codable>(
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
        return try await executeRequest(urlRequest, endpoint: endpoint, responseType: responseType, isRetry: isRetry)
    }
    
    
    /// APIResponseProtocol타입-Multipart 요청 async throws 메서드 (request, url, 헤더, body 설정만)
    func requestWithMultipart<U: APIResponseProtocol & Codable>(
        endpoint: EndpointProtocol,
        textFields: [String: Any] = [:],
        imageFields: [String: UIImage] = [:],
        responseType: U.Type,
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
        
        // Multipart boundary 생성
        let boundary = "Boundary-\(UUID().uuidString)"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // 필요 시 인증 헤더 추가
        if endpoint.requiresAuth {
            guard let accessToken = tokenManager.getAccessToken() else {
                throw NetworkError.unauthorized
            }
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Multipart body 생성
        urlRequest.httpBody = createMultipartBody(
            boundary: boundary,
            textFields: textFields,
            imageFields: imageFields
        )
        
        // 네트워크 요청 실행
        return try await executeRequest(urlRequest, endpoint: endpoint, responseType: responseType, isRetry: isRetry)
    }
    
    
    /// APIResponseProtocol타입-네트워크 요청 실행 로직
    private func executeRequest<U: APIResponseProtocol & Codable>(
        _ urlRequest: URLRequest,
        endpoint: EndpointProtocol,
        responseType: U.Type,
        isRetry: Bool = false
    ) async throws -> U {
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            let apiResponse = try parseAPIResponse(data, responseType: responseType)

            // 상태 코드별 처리
            switch httpResponse.statusCode {
            case 200...299:
                if apiResponse.success {
                    return apiResponse
                } else {
                    // 200 상태 코드지만 success=false 인 경우
                    // 이 경우는 없나??
                    throw NetworkError.serverError(httpResponse.statusCode, apiResponse.message)
                }
                
            case 401:
                // 인증 실패 - 토큰 리프레시 시도(재시도가 아닌 경우에만)
                if endpoint.requiresAuth && !isRetry {
                    let refreshSuccess = try await refreshTokenIfNeeded()
                    
                    // 리프레시 토큰 성공 시 재시도
                    if refreshSuccess {
                        // 새로운 토큰으로 헤더 업데이트
                        var retryRequest = urlRequest
                        if let newAccessToken = tokenManager.getAccessToken() {
                            retryRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")
                        }
                        
                        return try await executeRequest(retryRequest, endpoint: endpoint, responseType: responseType, isRetry: true)
                    }
                }
                // 다시 401일 때 throw
                throw NetworkError.unauthorized
                
            default:
                throw NetworkError.serverError(httpResponse.statusCode, apiResponse.message)
            }
        } catch {
            if error is NetworkError { throw error }
            else { throw NetworkError.networkError(error) }
        }
    }
}

extension APIClient {
    
    /// Multipart body 생성
    private func createMultipartBody(
        boundary: String,
        textFields: [String: Any],
        imageFields: [String: UIImage]
    ) -> Data {
        var body = Data()
        
        // 텍스트 필드 추가 (자동 타입 변환)
        for (key, value) in textFields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            
            // 타입별 자동 변환
            let stringValue: String
            switch value {
            case let boolValue as Bool:
                stringValue = boolValue ? "true" : "false"
            case let intValue as Int:
                stringValue = String(intValue)
            case let doubleValue as Double:
                stringValue = String(doubleValue)
            case let floatValue as Float:
                stringValue = String(floatValue)
            case let str as String:
                stringValue = str
            case let optionalValue where optionalValue is OptionalProtocol:
                // Optional 타입 처리
                if let unwrapped = Mirror(reflecting: optionalValue).children.first?.value {
                    stringValue = String(describing: unwrapped)
                } else {
                    stringValue = ""
                }
            case let codableValue as Codable:
                // Codable 객체를 JSON 문자열로 변환 (Quote 배열 등)
                if let jsonData = try? JSONEncoder().encode(codableValue),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    stringValue = jsonString
                } else {
                    stringValue = String(describing: codableValue)
                }
            case let arrayValue as [String]:
                // 문자열 배열의 경우 각각을 개별 필드로 추가
                for item in arrayValue {
                    body.append("--\(boundary)\r\n")
                    body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.append("\(item)\r\n")
                }
                continue
            case let arrayValue as [Any]:
                // 다른 배열을 JSON 문자열로 변환
                if let jsonData = try? JSONSerialization.data(withJSONObject: arrayValue),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    stringValue = jsonString
                } else {
                    stringValue = String(describing: arrayValue)
                }
            case let dictValue as [String: Any]:
                // 딕셔너리를 JSON 문자열로 변환
                if let jsonData = try? JSONSerialization.data(withJSONObject: dictValue),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    stringValue = jsonString
                } else {
                    stringValue = String(describing: dictValue)
                }
            default:
                stringValue = String(describing: value)
            }

            body.append("\(stringValue)\r\n")
        }
        
        // 이미지 필드 추가 (리사이즈 포함)
        for (key, image) in imageFields {
            // 이미지를 400px 너비로 리사이즈
            let processedImage = image.resizeWithWidth(width: 400) ?? image
            if let imageData = processedImage.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(imageData)
                body.append("\r\n")
            }
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    /// APIResponseProtocol 타입으로 응답 파싱
    private func parseAPIResponse<T: APIResponseProtocol & Codable>(_ data: Data, responseType: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            // json decode 실패
            throw NetworkError.decodingError(error)
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

// Optional 타입 감지를 위한 프로토콜
private protocol OptionalProtocol {}
extension Optional: OptionalProtocol {}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
