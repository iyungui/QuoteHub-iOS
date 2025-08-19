//
//  InAppPurchaseManager.swift
//  QuoteHub
//
//  Created by iyungui on 8/19/25.
//

import Foundation
import StoreKit

@MainActor
@Observable
final class InAppPurchaseManager {
    
    // MARK: - SINGLETON
    static let shared = InAppPurchaseManager()
    private init() {
        // 1. 먼저 캐시된 구독 상태 로드 (빠른 UI 업데이트)
        loadCachedSubscriptionStatus()
        
        // 2. 백그라운드에서 실제 Apple 서버 상태 확인
        Task {
            await updateCustomerInfo()
        }
        
        // 3. 실시간 트랜잭션 변경 감지 시작
        listenForTransactions()
    }
    
    // MARK: - PROPERTIES
    
    /// 현재 사용 가능한 제품들
    private(set) var products: [Product] = []
    
    /// 현재 구매 상태
    private(set) var purchaseStatus: PurchaseStatus = .notPurchased
    
    /// 로딩 상태
    private(set) var isLoading = false
    
    /// 에러 메시지
    private(set) var errorMessage: String?
    
    /// 프리미엄 사용자 여부
    var isPremiumUser: Bool {
        return purchaseStatus == .purchased
    }
    
    // MARK: - PRODUCT IDS
    
    /// 앱스토어 커넥트에서 설정할 제품 ID (일회성 구매)
    private let productIds: Set<String> = [
        "com.quotehub.premium.lifetime"  // 영구 프리미엄 (한번 구매)
    ]
    
    // MARK: - PUBLIC METHODS
    
    /// 제품 정보 로드
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            products = try await Product.products(for: productIds)
            print("✅ 제품 로드 성공: \(products.count)개")
        } catch {
            print("❌ 제품 로드 실패: \(error)")
            errorMessage = "제품 정보를 불러올 수 없습니다."
        }
        
        isLoading = false
    }
    
    /// 프리미엄 구매 시작
    func purchasePremium(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                
                // 구매 상태 업데이트
                await updateCustomerInfo()
                
                print("✅ 구매 성공: \(product.displayName)")
                isLoading = false
                return true
                
            case .userCancelled:
                print("⚠️ 사용자가 구매를 취소했습니다")
                isLoading = false
                return false
                
            case .pending:
                print("⏳ 구매가 대기 중입니다")
                isLoading = false
                return false
                
            @unknown default:
                print("❌ 알 수 없는 구매 결과")
                errorMessage = "구매 처리 중 오류가 발생했습니다."
                isLoading = false
                return false
            }
            
        } catch {
            print("❌ 구매 실패: \(error)")
            errorMessage = handlePurchaseError(error)
            isLoading = false
            return false
        }
    }
    
    /// 구매 복원
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updateCustomerInfo()
            print("✅ 구매 복원 완료")
        } catch {
            print("❌ 구매 복원 실패: \(error)")
            errorMessage = "구매 복원에 실패했습니다."
        }
        
        isLoading = false
    }
    
    /// 앱이 포그라운드로 돌아올 때 구매 상태 새로고침
    func refreshPurchaseStatus() {
        Task {
            await updateCustomerInfo()
        }
    }
    
    /// 에러 메시지 초기화
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - PRIVATE METHODS
    
    /// 캐시된 구매 상태 로드 (빠른 초기화)
    private func loadCachedSubscriptionStatus() {
        let cachedStatus = UserDefaults.standard.bool(forKey: "is_premium_purchased_cached")
        purchaseStatus = cachedStatus ? .purchased : .notPurchased
        print("📱 캐시된 구매 상태 로드: \(purchaseStatus.displayText)")
    }
    
    /// 구매 상태 캐시에 저장
    private func saveCachedSubscriptionStatus() {
        UserDefaults.standard.set(isPremiumUser, forKey: "is_premium_purchased_cached")
        print("💾 구매 상태 캐시 저장: \(purchaseStatus.displayText)")
    }
    
    /// 고객 정보 및 구독 상태 업데이트
    private func updateCustomerInfo() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // 구독 제품인지 확인
                if productIds.contains(transaction.productID) {
                    purchaseStatus = .purchased
                    print("✅ 활성 구독 발견: \(transaction.productID)")
                    return
                }
            } catch {
                print("❌ 트랜잭션 검증 실패: \(error)")
            }
        }
        
        // 활성 구독이 없음
        purchaseStatus = .notPurchased
        print("⚠️ 활성 구독 없음")
    }
    
    /// 트랜잭션 변경 사항 모니터링
    private func listenForTransactions() {
        Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await transaction.finish()
                    await updateCustomerInfo()
                } catch {
                    print("❌ 트랜잭션 업데이트 처리 실패: \(error)")
                }
            }
        }
    }
    
    /// 트랜잭션 검증
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw IAPError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    /// 구매 에러 처리
    private func handlePurchaseError(_ error: Error) -> String {
        if let storeKitError = error as? StoreKitError {
            switch storeKitError {
            case .networkError:
                return "네트워크 연결을 확인해주세요."
            case .systemError:
                return "시스템 오류가 발생했습니다."
            case .notAvailableInStorefront:
                return "현재 지역에서는 구매할 수 없습니다."
            case .notEntitled:
                return "구매 권한이 없습니다."
            default:
                return "구매 중 오류가 발생했습니다."
            }
        }
        return "알 수 없는 오류가 발생했습니다."
    }
}

// MARK: - PURCHASE STATUS

enum PurchaseStatus {
    case notPurchased
    case purchased
    
    var displayText: String {
        switch self {
        case .notPurchased:
            return "무료 사용자"
        case .purchased:
            return "프리미엄 사용자"
        }
    }
}

// MARK: - IAP ERROR

enum IAPError: Error {
    case failedVerification
    case system(Error)
    
    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "구매 검증에 실패했습니다."
        case .system(let error):
            return error.localizedDescription
        }
    }
}
