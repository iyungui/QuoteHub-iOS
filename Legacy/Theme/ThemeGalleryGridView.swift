////
////  ThemeGalleryGridView.swift
////  QuoteHub
////
////  Created by 이융의 on 6/5/25.
////
//
//import SwiftUI
//
//// MARK: - THEME GALLERY GRID VIEW
//
//struct ThemeGalleryGridView: View {
//    let isMy: Bool
//    let loadType: LoadType
//    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
//    @EnvironmentObject private var userViewModel: UserViewModel
//    
//    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
//
//    var body: some View {
//        LazyVStack(spacing: 0) {
//            if storiesViewModel.bookStories(for: loadType).isEmpty && !storiesViewModel.isLoading {
//                emptyStateView
//                    .padding(.top, 40)
//            } else {
//                LazyVGrid(columns: columns, spacing: 1) {
//                    ForEach(storiesViewModel.bookStories(for: loadType), id: \.id) { story in
//                        StoryGridCard(story: story, isMy: isMy)
//                            .environmentObject(storiesViewModel)
//                            .environmentObject(userViewModel)
//                            .onAppear {
//                                // 마지막 몇 개 아이템에 도달했을 때 더 로드
//                                let stories = storiesViewModel.bookStories(for: loadType)
//                                if let lastStory = stories.last,
//                                   story.id == lastStory.id,
//                                   !storiesViewModel.isLastPage,
//                                   !storiesViewModel.isLoading {
//                                    storiesViewModel.loadMoreIfNeeded(currentItem: story, type: loadType)
//                                }
//                            }
//                    }
//                    
//                    // 더 로딩 중일 때 로딩 인디케이터
//                    if !storiesViewModel.isLastPage && storiesViewModel.isLoading && !storiesViewModel.bookStories(for: loadType).isEmpty {
//                        ForEach(0..<3, id: \.self) { _ in
//                            loadingGridCard
//                        }
//                    }
//                }
////                .padding(.horizontal, 4)
//            }
//        }
////        .padding(.top, 8)
//    }
//    
//    private var emptyStateView: some View {
//        VStack(spacing: 24) {
//            Image(systemName: "folder.badge.questionmark")
//                .font(.system(size: 50))
//                .foregroundColor(.secondaryText.opacity(0.6))
//            
//            VStack(spacing: 8) {
//                Text("아직 북스토리가 없어요")
//                    .font(.scoreDream(.bold, size: .title3))
//                    .foregroundColor(.primaryText)
//                
//                Text(isMy ? "이 테마에 첫 번째 북스토리를 추가해보세요!" : "이 테마에는 아직 북스토리가 없습니다.")
//                    .font(.scoreDream(.medium, size: .subheadline))
//                    .foregroundColor(.secondaryText)
//                    .multilineTextAlignment(.center)
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 80)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.antiqueGold.opacity(0.2), lineWidth: 1)
//                )
//        )
//        .padding(.horizontal, 20)
//    }
//    
//    private var loadingGridCard: some View {
//        Rectangle()
//            .fill(Color.paperBeige.opacity(0.3))
//            .aspectRatio(1, contentMode: .fit)
//            .overlay(
//                ProgressView()
//                    .scaleEffect(0.8)
//                    .tint(.brownLeather)
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 8))
//    }
//}
