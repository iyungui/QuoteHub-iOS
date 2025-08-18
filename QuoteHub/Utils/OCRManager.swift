//
//  OCRManager.swift
//  QuoteHub
//
//  Created by iyungui on 8/18/25.
//

import Foundation
@preconcurrency import Vision
import UIKit

@MainActor
@Observable
final class OCRManager {
    // singleton
    
    static let shared = OCRManager()
    private init() {}
    
    // MARK: - PUBLIC METHODS
    
    /// 이미지에서 텍스트 추출
    /// - Parameters:
    ///     - image: 텍스트를 추출할 이미지
    ///     - completion: 완료 콜백 (성공: 추출된 텍스트, 실패: nil)
    func extractText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            print("OCR: CGImage 변환 실패")
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                self.handleTextRecognition(
                    request: request,
                    error: error,
                    completion: completion
                )
            }
        }
        
        // OCR 설정
        configureOCRRequest(request)
        
        // 백그라운드에서 OCR 처리
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("OCR 처리 실패: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
    // MARK: - PRIVATE METHODS
    
    /// OCR 요청 설정
    private func configureOCRRequest(_ request: VNRecognizeTextRequest) {
        // 인식 정확도 설정
        request.recognitionLevel = .accurate
        
        // 언어 설정
        request.recognitionLanguages = ["ko-KR", "en-US"]
        
        // 자동 언어 감지 활성화
        request.automaticallyDetectsLanguage = true
        
        // 텍스트 인식 개선 위한 추가 설정
        request.usesLanguageCorrection = true
    }
    
    /// 텍스트 인식 결과 처리
    private func handleTextRecognition(
        request: VNRequest,
        error: Error?,
        completion: @escaping (String?) -> Void
    ) {
        if let error = error {
            print("OCR 인식 실패: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            print("OCR: 인식 결과 가져올 수 없음")
            completion(nil)
            return
        }
        
        // 인식된 텍스트들을 배열로 수집
        let recognizedStrings = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        
        guard !recognizedStrings.isEmpty else {
            print("OCR: 텍스트 찾을 수 없음")
            completion(nil)
            return
        }
        
        // 텍스트 정리 및 결합
        let extractedText = processRecognizedText(recognizedStrings)
        
        print("OCR Success: \(recognizedStrings.count)개 텍스트 라인 인식")
        print("추출된 텍스트: \(extractedText.prefix(100))...")
        
        completion(extractedText)
    }
    
    /// 인식된 텍스트 후처리
    private func processRecognizedText(_ recognizedStrings: [String]) -> String {
        let cleanedStrings = recognizedStrings.map { line in
            line.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        
        // 줄바꿈으로 결합
        let combinedText = cleanedStrings.joined(separator: "\n")
        
        // 연속된 줄바꿈 정리 (3개 이상의 연속 줄바꿈을 2개로 제한)
        let cleanedText = combinedText.replacingOccurrences(
            of: "\n{3,}",
            with: "\n\n",
            options: .regularExpression
        )
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - UIImage Extension

extension UIImage {
    
    /// 간편한 OCR 텍스트 추출 메서드
    /// - Parameter completion: 완료 콜백 (성공: 추출된 텍스트, 실패: nil)
    @MainActor func extractText(completion: @escaping (String?) -> Void) {
        OCRManager.shared.extractText(from: self, completion: completion)
    }
    
    /// 동기식 OCR 텍스트 추출 (async/await)
    /// - Returns: 추출된 텍스트 (실패 시 nil)
    @MainActor
    func extractTextAsync() async -> String? {
        await withCheckedContinuation { continuation in
            extractText { result in
                continuation.resume(returning: result)
            }
        }
    }
}
