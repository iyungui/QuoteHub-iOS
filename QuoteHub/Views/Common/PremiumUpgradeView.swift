//
//  PremiumUpgradeView.swift
//  QuoteHub
//
//  Created by iyungui on 8/19/25.
//

import SwiftUI
import StoreKit

struct PremiumUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var premiumProduct: Product?
    @State private var hasLoadedOnce = false
    @State private var showingRestoreSuccess = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더
                    headerSection
                    
                    // 프리미엄 기능 소개
                    featuresSection
                    
                    // 구매 버튼
                    purchaseButtonSection
                    
                    // 약관 및 복원
                    footerSection
                }
                .padding()
            }
            .backgroundGradient()
            .navigationTitle("프리미엄 업그레이드")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .alert("오류", isPresented: .constant(InAppPurchaseManager.shared.errorMessage != nil)) {
                Button("확인") {
                    InAppPurchaseManager.shared.clearError()
                }
                Button("재시도") {
                    retryLoadProducts()
                }
            } message: {
                if let errorMessage = InAppPurchaseManager.shared.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert("구매 복원 완료", isPresented: $showingRestoreSuccess) {
                Button("확인") {}
            } message: {
                Text("프리미엄 구독이 성공적으로 복원되었습니다.")
            }
            .task {
                if !hasLoadedOnce {
                    hasLoadedOnce = true
                    await loadProductsWithRetry()
                }
            }
            .progressOverlay(viewModels: InAppPurchaseManager.shared, opacity: true)
            .refreshable {
                await loadProductsWithRetry()
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
            
            VStack(spacing: 8) {
                Text("문장모아 프리미엄")
                    .font(.appFont(.bold, size: .title1))
                    .foregroundColor(.primary)
                
                Text("무제한 OCR과 커스텀 폰트 사용 가능")
                    .font(.appFont(.medium, size: .subheadline))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            Text("프리미엄 기능")
                .font(.appFont(.bold, size: .body))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "text.viewfinder",
                    title: "무제한 OCR",
                    description: "하루 10회 제한 없이 무제한으로 사용",
                    isPremium: true
                )
                
                FeatureRow(
                    icon: "textformat.ko",
                    title: "커스텀 폰트",
                    description: "10개의 폰트 자유롭게 사용 가능",
                    isPremium: true
                )
                
                FeatureRow(
                    icon: "heart",
                    title: "개발자 지원",
                    description: "앱 개발과 새로운 기능 추가 지원",
                    isPremium: true
                )
                
                Text("프리미엄 혜택은 계속 추가됩니다.")
                    .font(.appCaption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.linearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Purchase Button Section
    
    private var purchaseButtonSection: some View {
        VStack(spacing: 16) {
            if let premiumProduct = premiumProduct {
                Button {
                    purchaseProduct(premiumProduct)
                } label: {
                    VStack(spacing: 8) {
                        Text("프리미엄 업그레이드")
                            .font(.appFont(.bold, size: .body))
                        Text("3,300₩")
                            .font(.appFont(.medium, size: .title2))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .blue.opacity(0.3), radius: 8)
                }
                .disabled(InAppPurchaseManager.shared.isLoading)
                
            } else if InAppPurchaseManager.shared.isLoading {
                // 로딩 중
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("제품 정보 로딩 중...")
                        .font(.appFont(.medium, size: .callout))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
            } else if InAppPurchaseManager.shared.products.isEmpty {
                // 제품 로드 실패 또는 제품 없음
                VStack(spacing: 12) {
                    Text("제품 정보를 불러올 수 없습니다")
                        .font(.appFont(.medium, size: .callout))
                        .foregroundColor(.secondary)
                    
                    Button("다시 시도") {
                        retryLoadProducts()
                    }
                    .font(.appFont(.medium, size: .callout))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack {
                Text("• 한번 구매로 영구 사용")
                Text("• 모든 기기에서 사용 가능")
                Text("• 환불 시 기간 내 가능")
                Text("• 폰트는 설정 창에서 변경 가능합니다.")
            }
            .font(.appFont(.regular, size: .caption))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Button("구매 복원") {
                restorePurchases()
            }
            .font(.appFont(.medium, size: .callout))
            .foregroundColor(.blue)
            .disabled(InAppPurchaseManager.shared.isLoading)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadProductsWithRetry() async {
        await InAppPurchaseManager.shared.loadProducts()
        premiumProduct = InAppPurchaseManager.shared.products.first
        
        // 디버깅용 출력
        if let product = premiumProduct {
            print("✅ 프리미엄 제품 설정 완료: \(product.id)")
        } else {
            print("⚠️ 프리미엄 제품이 없습니다. 제품 수: \(InAppPurchaseManager.shared.products.count)")
        }
    }
    
    private func retryLoadProducts() {
        Task {
            await loadProductsWithRetry()
        }
    }
    
    private func purchaseProduct(_ product: Product) {
        Task {
            let success = await InAppPurchaseManager.shared.purchasePremium(product)
            if success {
                print("✅ 구매 성공")
                dismiss()
            }
        }
    }
    
    private func restorePurchases() {
        Task {
            let wasPremium = InAppPurchaseManager.shared.isPremiumUser
            await InAppPurchaseManager.shared.restorePurchases()
            
            // 복원 후 프리미엄 상태가 되었다면 성공 메시지 표시
            if !wasPremium && InAppPurchaseManager.shared.isPremiumUser {
                showingRestoreSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isPremium: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isPremium ? .orange : .blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.appFont(.medium, size: .callout))
                        .foregroundColor(.primary)
                    
                    if isPremium {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(description)
                    .font(.appFont(.regular, size: .caption))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PremiumUpgradeView()
}
