//
//  SetThemeView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/8/23.
//

import SwiftUI
import SDWebImageSwiftUI

/// 북스토리 생성 4 (option): 테마 선택/만들기링크 뷰
struct SetThemeView: View {
    
    // MARK: - PROPERTIES
    
    @Binding var selectedThemeIds: [String]
    @StateObject private var themesViewModel = ThemesViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // 테마 선택 상태를 관리하는 Set
    @State private var selectedSet = Set<String>()
    
    // MARK: - BODY
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 새 테마 만들기 섹션
                        createNewThemeSection
                        
                        Divider().foregroundStyle(Color.paperBeige)
                        
                        // 내 테마 목록
                        myThemesSection
                        
                        // 하단 여백
                        spacer(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("테마 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        selectedThemeIds = Array(selectedSet)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .progressOverlay(viewModel: themesViewModel, animationName: "progressLottie", opacity: true)
            .onAppear {
                setupInitialData()
            }
        }
    }
    
    // MARK: - UI Components
    
    private var createNewThemeSection: some View {
        VStack(spacing: 16) {
            
            NavigationLink(destination: CreateThemeView(mode: .embedded)
                .environmentObject(themesViewModel)
            ) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.brownLeather, .antiqueGold]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "plus")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("새 테마 만들기")
                            .font(.scoreDream(.bold, size: .body))
                            .foregroundColor(.primaryText)
                        
                        Text("나만의 테마를 생성해보세요")
                            .font(.scoreDream(.light, size: .caption))
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondaryText.opacity(0.6))
                }
                .padding(20)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(CardButtonStyle())
        }
    }
    
    private var myThemesSection: some View {
        VStack(spacing: 16) {
            HStack {
                cardHeader(title: "내 테마 목록", icon: "folder.fill")
                
                Spacer()
                
                if !selectedSet.isEmpty {
                    Text("\(selectedSet.count)개 선택됨")
                        .font(.scoreDream(.medium, size: .caption))
                        .foregroundColor(.brownLeather)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.brownLeather.opacity(0.1))
                        )
                }
            }
            
            if themesViewModel.themes(for: .my).isEmpty && !themesViewModel.isLoading {
                emptyThemeView
            } else {
                themeGridView
            }
        }
    }
    
    private var emptyThemeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.secondaryText.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("아직 테마가 없어요")
                    .font(.scoreDream(.bold, size: .body))
                    .foregroundColor(.primaryText)
                
                Text("지금 바로 나만의 테마를 만들어보세요!")
                    .font(.scoreDream(.light, size: .subheadline))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
    
    private var themeGridView: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 20
        ) {
            ForEach(themesViewModel.themes(for: .my), id: \.id) { theme in
                ThemeGridCard(
                    theme: theme,
                    isSelected: selectedSet.contains(theme.id),
                    onTap: {
                        toggleThemeSelection(theme.id)
                    }
                )
            }
            
            // 더 로드할 테마가 있을 때 로딩 인디케이터
            if !themesViewModel.isLastPage {
                GridLoadingView()
                    .onAppear {
                        themesViewModel.loadMoreIfNeeded(
                            currentItem: themesViewModel.themes(for: .my).last,
                            type: .my
                        )
                    }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.clear,
                                Color.antiqueGold.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    private func cardHeader(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3.weight(.medium))
                .foregroundColor(.brownLeather)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.scoreDream(.bold, size: .body))
                .foregroundColor(.primaryText)
        }
    }
    
    // MARK: - Methods
    
    private func setupInitialData() {
        // 기존 선택된 테마들을 Set에 추가
        selectedSet = Set(selectedThemeIds)
        
        // 내 테마 목록 로드
        themesViewModel.loadThemes(type: .my)
    }
    
    private func toggleThemeSelection(_ themeId: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedSet.contains(themeId) {
                selectedSet.remove(themeId)
            } else {
                selectedSet.insert(themeId)
            }
        }
    }
}

// MARK: - Theme Grid Card

struct ThemeGridCard: View {
    let theme: Theme
    let isSelected: Bool
    let onTap: () -> Void
    
    private let cardWidth: CGFloat = (UIScreen.main.bounds.width - 60) / 2
    private let cardHeight: CGFloat = 160
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 배경 이미지
                backgroundImage
                
                // 그라데이션 오버레이
                gradientOverlay
                
                // 선택 상태 오버레이
                if isSelected {
                    selectionOverlay
                }
                
                // 컨텐츠
                contentView
                
                // 선택 체크마크
                selectionIndicator
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.brownLeather : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 0.95 : 1.0)
            .shadow(
                color: isSelected ? .brownLeather.opacity(0.3) : .black.opacity(0.1),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var backgroundImage: some View {
        WebImage(url: URL(string: theme.themeImageURL))
            .placeholder {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.paperBeige.opacity(0.8),
                                Color.antiqueGold.opacity(0.6),
                                Color.brownLeather.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: cardWidth, height: cardHeight)
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                Color.black.opacity(0.3),
                Color.black.opacity(0.6)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var selectionOverlay: some View {
        Rectangle()
            .fill(Color.brownLeather.opacity(0.2))
    }
    
    private var contentView: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(theme.name)
                    .font(.scoreDream(.bold, size: .subheadline))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                if !theme.description.isEmpty {
                    Text(theme.description)
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    private var selectionIndicator: some View {
        VStack {
            HStack {
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3.weight(.bold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .background(
                        Circle()
                            .fill(isSelected ? Color.brownLeather : Color.black.opacity(0.3))
                            .frame(width: 24, height: 24)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.trailing, 12)
            .padding(.top, 12)
            
            Spacer()
        }
    }
}

// MARK: - Grid Loading View

struct GridLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.brownLeather)
            
            Text("더 불러오는 중...")
                .font(.scoreDream(.light, size: .caption))
                .foregroundColor(.secondaryText)
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.paperBeige.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [8]))
                )
        )
    }
}

#Preview {
    SetThemeView(selectedThemeIds: .constant([]))
}
