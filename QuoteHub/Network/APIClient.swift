//
//  APIClient.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import SwiftUI

final class APIClient {
    // MARK: - Properties
    static let shared = APIClient()
    
    private let session: URLSession
    private let tokenManager: KeyChainTokenManager
    
    // MARK: - Initialization
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        
        self.session = URLSession(configuration: config)
        self.tokenManager = KeyChainTokenManager()
    }
    
    // MARK: - Public Methods
    
    /// Codable body를 받는 request 메서드
    func request<T: APIResponseProtocol & Codable>( // 제네릭 타입 T 정의 (APIResponseProtocol과 Codable을 준수해야 함)
        endpoint: EndpointProtocol,
        body: RequestBody = .empty, // 요청 Body
        responseType: T.Type,   // 응답을 어떤 타입으로 파싱할지 지정
        customHeaders: [String: String]? = nil,
        isRetry: Bool = false   // 재시도 요청인지 여부 (토큰 갱신 후 재시도할 때 true)
    ) async throws -> T {
        
        // URL 검증
        guard let url = URL(string: endpoint.fullURL) else {
            throw NetworkError.invalidURL
        }
        
        // URLRequest 기본 설정
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        
        if let accessToken = tokenManager.getAccessToken() {
            // 토큰이 있으면 항상 헤더에 추가 (공개 API든 인증 API든)
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else if endpoint.requiresAuth {
            // 토큰이 없는데 인증이 필수면 에러
            throw NetworkError.unauthorized
        }
        
        // 커스텀 헤더 설정
        customHeaders?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Body 타입에 따른 요청 처리
        switch body {
        case .empty:
            // EmptyData - Body 없음
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        case .codable(let encodableObject):
            // Codable 객체 JSON 인코딩
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try encodeToJSON(encodableObject)
            
        case .dictionary(let dict):
            // [String: Any] 딕셔너리 JSON 인코딩
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try encodeToJSON(dict)

        case .multipart(let textFields, let singleImages, let imageArrays):
            // Multipart 요청 처리
            let boundary = "Boundary-\(UUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = createMultipartBody(
                boundary: boundary,
                textFields: textFields,
                singleImages: singleImages,
                imageArrays: imageArrays
            )
        }
        
        return try await executeRequest(urlRequest, endpoint: endpoint, responseType: responseType, isRetry: isRetry)
    }
    
    /// 현재 유효한 액세스 토큰 반환
    func getValidAccessToken() -> String? {
        return tokenManager.getAccessToken()
    }
    
    // MARK: - Private Methods
    
    /// 네트워크 요청 실행 및 응답 처리
    private func executeRequest<T: APIResponseProtocol & Codable>(
        _ urlRequest: URLRequest,
        endpoint: EndpointProtocol,
        responseType: T.Type,
        isRetry: Bool = false
    ) async throws -> T {
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            // HTTP 응답 검증
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // JSON 응답 파싱
            let apiResponse = try parseAPIResponse(data, responseType: responseType)

            // HTTP 상태 코드별 처리
            switch httpResponse.statusCode {
            case 200...299:
                if apiResponse.success {
                    return apiResponse
                } else {
                    throw NetworkError.serverError(httpResponse.statusCode, apiResponse.message)
                }
                
            case 401:
                if endpoint.requiresAuth && !isRetry {
                    let refreshSuccess = try await refreshTokenIfNeeded()
                    
                    if refreshSuccess {
                        // 토큰 갱신 성공 시 재시도
                        var retryRequest = urlRequest
                        if let newAccessToken = tokenManager.getAccessToken() { // 여기서, 새로받은 토큰 가져와서 (1)
                            retryRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")
                        }
                        
                        // 해당 인증 헤더로 재시도 (isRetry는 true로)
                        return try await executeRequest(retryRequest, endpoint: endpoint, responseType: responseType, isRetry: true)
                    }
                }
                throw NetworkError.unauthorized
                
            default:
                throw NetworkError.serverError(httpResponse.statusCode, apiResponse.message)
            }
        } catch {
            if error is NetworkError { throw error }
            else { throw NetworkError.networkError(error) }
        }
    }
    
    /// JSON 응답 파싱
    private func parseAPIResponse<T: APIResponseProtocol & Codable>(_ data: Data, responseType: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            // 디코딩 실패 시 디버깅 정보 출력
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("JSON 파싱 실패 - 타입: \(responseType)")
                print("디코딩 에러: \(error)")
                print("서버 응답 내용: \(responseString)")
            }
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Codable 객체를 JSON Data로 인코딩
    private func encodeToJSON(_ object: Encodable) throws -> Data {
        do {
            return try JSONEncoder().encode(object)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// [String: Any] 딕셔너리를 JSON Data로 인코딩 (오버로딩)  - Quotes 배열 인코딩에 사용
    private func encodeToJSON(_ dictionary: [String: Any]) throws -> Data {
        // Quote 배열 처리를 위한 전처리
        var processedDict = dictionary
        
        for (key, value) in dictionary {
            if let quotesArray = value as? [Quote] {
                // Quote 배열을 딕셔너리 배열로 변환
                let quoteDicts = quotesArray.map { quote in
                    var dict: [String: Any] = ["quote": quote.quote]
                    if let page = quote.page {
                        dict["page"] = page
                    }
                    return dict
                }
                processedDict[key] = quoteDicts
            }
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: processedDict)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Multipart form-data Body 생성
    private func createMultipartBody(
        boundary: String,
        textFields: [String: Any],
        singleImages: [String: UIImage],
        imageArrays: [String: [UIImage]]
    ) -> Data {
        var body = Data()
        
        // 텍스트 필드 추가
        for (key, value) in textFields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(convertToString(value))\r\n")
        }
        
        // 단일 이미지 필드 추가
        for (key, image) in singleImages {
            if let imageData = prepareImageData(image) {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(imageData)
                body.append("\r\n")
            }
        }
        
        // 이미지 배열 필드 추가 (같은 name으로 여러 파일)
        for (key, images) in imageArrays {
            for (index, image) in images.enumerated() {
                if let imageData = prepareImageData(image) {
                    body.append("--\(boundary)\r\n")
                    body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key)_\(index).jpg\"\r\n")
                    body.append("Content-Type: image/jpeg\r\n\r\n")
                    body.append(imageData)
                    body.append("\r\n")
                }
            }
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }

    /// 값을 문자열로 변환 (Quote 배열 특별 처리 포함)
    private func convertToString(_ value: Any) -> String {
        if let quotesArray = value as? [Quote] {
            // Quote 배열을 JSON 문자열로 변환
            let quoteDicts = quotesArray.map { quote in
                var dict: [String: Any] = ["quote": quote.quote]
                if let page = quote.page {
                    dict["page"] = page
                }
                return dict
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: quoteDicts)
                return String(data: jsonData, encoding: .utf8) ?? "[]"
            } catch {
                return "[]"
            }
        } else if let stringArray = value as? [String] {
            // String 배열을 JSON 문자열로 변환
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: stringArray)
                return String(data: jsonData, encoding: .utf8) ?? "[]"
            } catch {
                return "[]"
            }
        } else if let boolValue = value as? Bool {
            return boolValue ? "true" : "false"
        } else {
            return String(describing: value)
        }
    }

    /// 이미지 데이터 준비 (리사이징 및 압축)
    private func prepareImageData(_ image: UIImage) -> Data? {
        let processedImage = image.resizeWithWidth(width: 400) ?? image
        return processedImage.jpegData(compressionQuality: 0.9)
    }

    /// 토큰 리프레시
    private func refreshTokenIfNeeded() async throws -> Bool {
        guard let refreshToken = tokenManager.getRefreshToken() else {
            return false
        }
        
        let headers = ["Authorization": "Bearer \(refreshToken)"]
        
        do {
            let response: APIResponse<RenewTokenResponse> = try await request(
                endpoint: AuthEndpoints.renewToken,
                body: .empty,
                responseType: APIResponse<RenewTokenResponse>.self,
                customHeaders: headers
            )
            
            guard let newAccessToken = response.data?.accessToken else {
                return false
            }
            
            try tokenManager.updateAccessToken(newAccessToken)
            return true
        } catch {
            print("토큰 리프레시 실패: \(error)")
            return false
        }
    }
}
