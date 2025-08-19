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
    @State private var iapManager = InAppPurchaseManager.shared
    @State private var premiumProduct: Product?
    
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
            .alert("오류", isPresented: .constant(iapManager.errorMessage != nil)) {
                Button("확인") {
                    iapManager.clearError()
                }
            } message: {
                if let errorMessage = iapManager.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                await iapManager.loadProducts()
                // 프리미엄 제품 할당 (첫 번째 제품)
                premiumProduct = iapManager.products.first
            }
            .overlay {
                if iapManager.isLoading {
                    LoadingOverlay()
                }
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
                
                Text("무제한 OCR과 더 많은 기능을 경험하세요")
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
                    icon: "photo.stack",
                    title: "고화질 이미지 저장",
                    description: "원본 화질로 이미지 저장 및 백업",
                    isPremium: true
                )
                
                FeatureRow(
                    icon: "icloud.and.arrow.up",
                    title: "클라우드 동기화",
                    description: "모든 기기에서 데이터 자동 동기화",
                    isPremium: true
                )
                
                FeatureRow(
                    icon: "sparkles",
                    title: "프리미엄 테마",
                    description: "독점 테마와 커스터마이징 옵션",
                    isPremium: true
                )
                
                FeatureRow(
                    icon: "heart",
                    title: "개발자 지원",
                    description: "앱 개발과 새로운 기능 추가 지원",
                    isPremium: true
                )
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
                    Task {
                        let success = await iapManager.purchasePremium(premiumProduct)
                        if success {
//                            dismiss()
                            print("구매성공?")
                        }
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text("프리미엄 업그레이드")
                            .font(.appFont(.bold, size: .body))
                        Text("\(premiumProduct.displayPrice)")
                            .font(.appFont(.medium, size: .title2))
                        Text("한번 구매로 영구 사용")
                            .font(.appFont(.regular, size: .caption))
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
                .disabled(iapManager.isLoading)
            } else {
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
            }
            
            Text("• 한번 구매로 영구 사용\n• 모든 기기에서 사용 가능\n• 환불 시 기간 내 가능")
                .font(.appFont(.regular, size: .caption))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Button("구매 복원") {
                Task {
                    await iapManager.restorePurchases()
                }
            }
            .font(.appFont(.medium, size: .callout))
            .foregroundColor(.blue)
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

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("처리 중...")
                    .font(.appFont(.medium, size: .callout))
                    .foregroundColor(.primary)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    PremiumUpgradeView()
}
