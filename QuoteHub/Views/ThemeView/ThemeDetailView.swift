//
//  ThemeDetailView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/8/23.
//

import SwiftUI
import SDWebImageSwiftUI

/// 테마 상세 뷰 (isMy 가 true인 경우, 수정하기 버튼 활성화)
struct ThemeDetailView: View {
    
    // MARK: - PROPERTIES
    
    let theme: Theme
    let isMy: Bool

    private var loadType: LoadType {
        return isMy ? .my : .public
    }
    
    init(theme: Theme, isMy: Bool) {
        self.theme = theme
        self.isMy = isMy
        _storiesViewModel = StateObject(wrappedValue: BookStoriesViewModel(themeId: theme.id))
    }
    
    @State private var selectedView: Int = 0  // 0: grid, 1: list
    @State private var showActionSheet: Bool = false
    
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @StateObject private var storiesViewModel: BookStoriesViewModel

    @State private var isEditing = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @Environment(\.dismiss) private var dismiss

    // MARK: - BODY
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 테마 헤더 이미지
                    themeHeaderView
                    
                    // 탭 인디케이터
                    TabIndicator(height: 3, selectedView: selectedView, tabCount: 2)
                    
                    // 컨텐츠 뷰
                    contentView
                }
            }
        }
        .navigationTitle(isMy ? "내 테마" : "테마")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isMy {
                ToolbarItem(placement: .navigationBarTrailing) {
                    themeMenuButton
                }
            }
        }
        .progressOverlay(viewModel: storiesViewModel, animationName: "progressLottie", opacity: true)
        .onAppear {
            storiesViewModel.loadBookStories(type: loadType)
        }
        .refreshable {
            storiesViewModel.refreshBookStories(type: loadType)
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인") {
                if alertMessage.contains("삭제") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .confirmationDialog("테마 관리", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("수정하기") {
                isEditing = true
            }
            Button("삭제하기", role: .destructive) {
                deleteTheme()
            }
        }
    }
    
    // MARK: - UI Components
    
    private var themeHeaderView: some View {
        ZStack {
            // 배경 이미지
            themeBackgroundImage
            
            // 그라데이션 오버레이
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 컨텐츠
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    // 테마 정보
                    VStack(alignment: .leading, spacing: 8) {
                        Text(theme.name)
                            .font(.scoreDream(.bold, size: .title1))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                        
                        if !theme.description.isEmpty {
                            Text(theme.description)
                                .font(.scoreDream(.medium, size: .body))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        }
                        
                        HStack(spacing: 12) {
                            // 공개/비공개 상태
                            HStack(spacing: 4) {
                                Image(systemName: theme.isPublic ? "eye.fill" : "eye.slash.fill")
                                    .font(.caption)
                                Text(theme.isPublic ? "공개" : "비공개")
                                    .font(.scoreDream(.medium, size: .caption))
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.3))
                            )
                            
                            // 생성일
                            Text("생성일: \(theme.createdAt.prefix(10))")
                                .font(.scoreDream(.light, size: .caption))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    // 뷰 전환 버튼들
                    HStack(spacing: 20) {
                        Spacer()
                        
                        Button(action: {
                                selectedView = 0
                            
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.subheadline.weight(.medium))
                                Text("그리드")
                                    .font(.scoreDream(.medium, size: .caption))
                            }
                            .foregroundColor(selectedView == 0 ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedView == 0 ? Color.appAccent : Color.clear)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .scaleEffect(selectedView == 0 ? 1.1 : 1.0)
                        }
                        
                        Button(action: {
//                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedView = 1
//                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "list.bullet")
                                    .font(.subheadline.weight(.medium))
                                Text("리스트")
                                    .font(.scoreDream(.medium, size: .caption))
                            }
                            .foregroundColor(selectedView == 1 ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedView == 1 ? Color.appAccent : Color.clear)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .scaleEffect(selectedView == 1 ? 1.1 : 1.0)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 300)
    }
    
    private var themeBackgroundImage: some View {
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
            .frame(width: UIScreen.main.bounds.width, height: 300)
            .clipped()
    }
    
    private var contentView: some View {
        Group {
            if selectedView == 0 {
                ThemeGalleryGridView(isMy: isMy, loadType: loadType)
                    .environmentObject(userViewModel)
                    .environmentObject(storiesViewModel)
            } else {
                ThemeGalleryListView(isMy: isMy, loadType: loadType)
                    .environmentObject(userViewModel)
                    .environmentObject(storiesViewModel)
            }
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .slide),
            removal: .opacity
        ))
    }
    
    private var themeMenuButton: some View {
        Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis")
        }
    }
    
    // MARK: - Methods
    
    private func deleteTheme() {
        themesViewModel.deleteFolder(folderId: theme.id) { isSuccess in
            if isSuccess {
                alertMessage = "테마가 성공적으로 삭제되었습니다."
            } else {
                alertMessage = "테마 삭제 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
            }
            showAlert = true
        }
    }
}
