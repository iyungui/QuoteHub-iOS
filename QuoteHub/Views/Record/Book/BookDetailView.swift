//
//  BookDetailView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/01.
//

import SwiftUI
//import SwiftData
import SDWebImageSwiftUI

/// 북스토리 기록 2: 책 상세 뷰
struct BookDetailView: View {
    let book: Book
    @State private var showAlert: Bool = false
    @State private var isImageLoaded: Bool = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Environment(UserAuthenticationManager.self) private var userAuthManager
    @State private var hasDraft: Bool = false

    // MARK: - BODY
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                bookImageAndBookTitle
                
                VStack(spacing: 24) {
                    // 도서 정보
                    bookInfoCard
                    
                    // 도서 소개(줄거리)
                    if !book.introduction.isEmpty {
                        introductionCard
                    }
                    
                    // 도서 정보 보기 & 북스토리 기록 버튼
                    if userAuthManager.isUserAuthenticated {
                        actionButtonsCard
                    }
                    
                    additionalInfoCard
                    
                    sourceCredit
                }
                .padding(.horizontal, 20)
                .padding(.top, -30) // Overlap with bookImageAndBookTitle section
                .padding(.bottom, 100) // Bottom spacing
            }
        }
        .backgroundGradient()
        .task {
            let manager = DraftManager(modelContext: modelContext)
            hasDraft = await manager.hasDraft(for: book.id)
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarHidden(true)
        .alert("알림", isPresented: $hasDraft) {
            NavigationLink {
                StoryQuotesRecordView(book: book, showDraft: true)
            } label: {
                Text("이어서 작성하기")
            }
            
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 책에 대한 임시저장된 글이 있습니다.")
        }
        .alert("외부 사이트로 이동", isPresented: $showAlert) {
            Button("확인") {
                if let url = URL(string: book.bookLink) {
                    UIApplication.shared.open(url)
                }
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("이 책에 대한 추가 정보를 외부 사이트에서 제공합니다. 외부 링크를 통해 해당 정보를 보시겠습니까?")
        }
        .overlay(
            // Custom Navigation
            customNavigationBar,
            alignment: .top
        )
    }
    
    // MARK: - UI COMPONENTS
    
    private var customNavigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.title2.weight(.medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
            
            Spacer()
            
            if userAuthManager.isUserAuthenticated {
                NavigationLink(destination: StoryQuotesRecordView(book: book)) {
                    Image(systemName: "highlighter")
                        .font(.title2.weight(.medium))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(.ultraThinMaterial))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }
    
    // MARK: - BOOK IMAGE & TITLE
    
    private var bookImageAndBookTitle: some View {
        ZStack {
            // Background with book cover blur effect
            GeometryReader { geometry in
                WebImage(url: URL(string: book.bookImageURL))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .blur(radius: 15)
                    .opacity(0.3)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.1),
                                Color.black.opacity(0.3),
                                Color.brownLeather.opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            // Content
            VStack(spacing: 20) {
                spacer(height: 100)
                
                bookImageView
                
                // Book Title
                VStack(spacing: 8) {
                    Text(book.title)
                        .font(.appFont(.bold, size: book.title.count > 20 ? .body : .title2))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                    
                    if !book.author.isEmpty {
                        Text(book.author.joined(separator: ", "))
                            .font(.appFont(.medium, size: .body))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal, 30)
                
                spacer(height: book.title.count > 20 ? 40 : 60)
            }
        }
        .frame(height: book.title.count > 20 ? 450 : 420)
    }
    
    private var bookImageView: some View {
        WebImage(url: URL(string: book.bookImageURL))
            .placeholder {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.paperBeige.opacity(0.3))
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.brownLeather.opacity(0.7))
                            
                            Text("표지 없음")
                                .font(.appFont(.light, size: .caption))
                                .foregroundColor(.brownLeather.opacity(0.7))
                        }
                    )
            }
            .resizable()
            .indicator(.activity)
            .scaledToFit()
            .frame(width: 140, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.black.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
            .scaleEffect(isImageLoaded ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isImageLoaded)
            .onAppear {
                withAnimation {
                    isImageLoaded = true
                }
            }
    }
    
    // MARK: - BOOK INFO CARD
    
    private var bookInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "도서 정보", icon: "info.circle.fill")
            
            VStack(spacing: 12) {
                if !book.author.isEmpty {
                    infoRow(label: "저자", value: book.author.joined(separator: ", "), icon: "person.fill")
                }
                
                if !book.translator.isEmpty {
                    infoRow(label: "옮긴이", value: book.translator.joined(separator: ", "), icon: "person.2.fill")
                }
                
                infoRow(label: "출판사", value: book.publisher, icon: "building.2.fill")
                
                if !book.publicationDatePrefix.isEmpty {
                    infoRow(label: "출간일", value: book.publicationDatePrefix, icon: "calendar")
                }
                
                if !book.ISBN.isEmpty {
                    infoRow(label: "ISBN", value: book.ISBN.joined(separator: ", "), icon: "barcode", isSmall: true)
                }
            }
        }
        .padding(24)
        .backgroundCard(cornerRadius: 20)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
    
    private var introductionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "책 소개", icon: "text.quote")
            
            Text(book.introduction)
                .font(.appFont(.regular, size: .subheadline))
                .foregroundColor(.primaryText)
                .lineLimit(nil)
                .lineSpacing(8)
        }
        .padding(24)
        .backgroundCard(cornerRadius: 20)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
    
    private var actionButtonsCard: some View {
        VStack(spacing: 12) {
//            cardHeader(title: "액션", icon: "hand.tap.fill")
            
            VStack(spacing: 10) {
                // External Link Button
                Button(action: { showAlert = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)
                        
                        Text("도서 정보 보기")
                            .font(.appFont(.medium, size: .subheadline))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.appAccent.opacity(0.8),
                                Color.appAccent.opacity(0.6)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(CardButtonStyle())
                
                // Record Button
                NavigationLink(destination: StoryQuotesRecordView(book: book)) {
                    HStack(spacing: 10) {
                        Image(systemName: "highlighter")
                            .font(.body.weight(.medium))
                            .foregroundColor(.white)

                        Text("북스토리 기록")
                            .font(.appFont(.medium, size: .subheadline))
                            .foregroundColor(.white)

                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white.opacity(0.8))

                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.brownLeather,
                                Color.antiqueGold
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(CardButtonStyle())
            }
        }
        .padding(24)
        .backgroundCard(cornerRadius: 20)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
    
    private var additionalInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            cardHeader(title: "추가 정보", icon: "info.square.fill")
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundColor(.secondaryText.opacity(0.7))
                    
                    Text("도서 상세 정보는 외부 링크를 통해 확인하실 수 있습니다.")
                        .font(.appFont(.light, size: .footnote))
                        .foregroundColor(.secondaryText)
                    
                    Spacer()
                }
                
                if !book.ISBN.isEmpty {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                            .font(.caption)
                            .foregroundColor(.secondaryText.opacity(0.7))
                        
                        Text("ISBN으로 다른 서점에서도 찾아보실 수 있습니다.")
                            .font(.appFont(.light, size: .footnote))
                            .foregroundColor(.secondaryText)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondaryCardBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.antiqueGold.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var sourceCredit: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundColor(.secondaryText.opacity(0.6))
                
                Text("출처: 카카오")
                    .font(.appFont(.light, size: .caption2))
                    .foregroundColor(.secondaryText.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.secondaryCardBackground.opacity(0.3))
            )
        }
        .padding(.top, 8)
    }
    
    // MARK: - Helper Views
    
    private func cardHeader(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.medium))
                .foregroundColor(.brownLeather)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.appFont(.bold, size: .body))
                .foregroundColor(.primaryText)
            
            Spacer()
            
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.antiqueGold.opacity(0.8),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .frame(maxWidth: 80)
        }
    }
    
    private func infoRow(label: String, value: String, icon: String, isSmall: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption.weight(.medium))
                .foregroundColor(.brownLeather.opacity(0.7))
                .frame(width: 16, height: 16)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.appFont(.medium, size: .subheadline))
                    .foregroundColor(.secondaryText)
                
                Text(value)
                    .font(.appFont(.regular, size: .footnote))
                    .foregroundColor(.primaryText)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.paperBeige.opacity(0.2))
        )
    }
}
