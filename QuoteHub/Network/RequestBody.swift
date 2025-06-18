//
//  RequestBody.swift
//  QuoteHub
//
//  Created by 이융의 on 6/18/25.
//

import SwiftUI

/// API 요청 Body 타입을 통합하는 enum
enum RequestBody {
    case empty                                    // EmptyData 대체
    case codable(Encodable)                      // Codable 객체
    case dictionary([String: Any])               // [String: Any] 딕셔너리
    case multipart(textFields: [String: Any],    // Multipart 요청
                  singleImages: [String: UIImage] = [:],
                  imageArrays: [String: [UIImage]] = [:])
}

/// Multipart 요청을 위한 구조체
struct MultipartData {
    let textFields: [String: Any]
    let singleImages: [String: UIImage]
    let imageArrays: [String: [UIImage]]
    
    init(textFields: [String: Any] = [:],
         singleImages: [String: UIImage] = [:],
         imageArrays: [String: [UIImage]] = [:]) {
        self.textFields = textFields
        self.singleImages = singleImages
        self.imageArrays = imageArrays
    }
}
