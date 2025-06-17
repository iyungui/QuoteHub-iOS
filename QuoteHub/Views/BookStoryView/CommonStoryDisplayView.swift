//
//  CommonStoryDisplayView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/13/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct CommonStoryDisplayView: View {
    let story: BookStory
    let isMyStory: Bool
    
    @EnvironmentObject private var detailViewModel: BookStoryDetailViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var commentViewModel: CommentViewModel
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 20) {
            // 이미지 섹션
            storyImagesSection
            
            // 컨텐츠 섹션
            storyContentSection.padding(.horizontal)
            
            if !isMyStory {
                // 프로필 섹션
                profileSection
            }
            
            // 책 정보 섹션
            bookInfoSection
            
            // 키워드 섹션
            keywordSection
            
            // 스토리 공개 여부와 작성일
            storyDateAndIsPublicSection
            
            Divider()
                .foregroundStyle(Color.secondaryText.opacity(0.3))
                .padding(.horizontal, 20)
            
            // 댓글창 toggle 버튼
            commentSheetToggleButton
        }
    }
    
    // 스토리 이미지 섹션
    @ViewBuilder
    private var storyImagesSection: some View {
        if let imageUrls = story.storyImageURLs, !imageUrls.isEmpty {
            let width: CGFloat = UIScreen.main.bounds.width
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, imageUrl in
                        VStack {
                            ZStack {
                                WebImage(url: URL(string: imageUrl))
                                    .placeholder {
                                        Rectangle()
                                            .fill(Color.paperBeige.opacity(0.3))
                                            .overlay(
                                                VStack(spacing: 12) {
                                                    Image(systemName: "photo")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.brownLeather.opacity(0.6))
                                                    Text("이미지 로딩 중...")
                                                        .font(.scoreDream(.light, size: .caption))
                                                        .foregroundColor(.secondaryText)
                                                }
                                            )
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: width - 50)
                                    .scrollTransition(axis: .horizontal) { content, phase in
                                        content
                                            .offset(x: phase.isIdentity ? 0 : phase.value * -200)
                                    }
                            }
                            .containerRelativeFrame(.horizontal)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
            }
            .contentMargins(32)
            .scrollTargetBehavior(.paging)
            .frame(height: width - 30) // 전체 높이 설정
        }
    }
    
    private var storyContentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if story.content != nil {
                Text("나의 생각")
                    .font(.scoreDream(.bold, size: .body))
                    .foregroundColor(.primaryText)
            }
            
            Text(story.content ?? "")
                .font(.scoreDream(.regular, size: .subheadline))
                .foregroundColor(.primaryText.opacity(0.8))
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .frame(minHeight: 60)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var profileSection: some View {
        HStack(spacing: 16) {
            ProfileImage(profileImageURL: story.userId.profileImage, size: 60)
            VStack(alignment: .leading, spacing: 6) {
                Text(story.userId.nickname)
                    .font(.scoreDream(.bold, size: .body))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(story.userId.statusMessage ?? "")
                    .font(.scoreDream(.medium, size: .subheadline))
                    .foregroundColor(.secondaryText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            NavigationLink(
                destination: LibraryView(otherUser: isMyStory ? nil : story.userId)
            ) {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondaryText.opacity(0.6))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var bookInfoSection: some View {
        NavigationLink(destination: {
            BookDetailView(book: story.bookId)
                .environmentObject(storiesViewModel)
                .environmentObject(userViewModel)
        }) {
            HStack(spacing: 16) {
                WebImage(url: URL(string: story.bookId.bookImageURL))
                    .placeholder {
                        Rectangle()
                            .fill(Color.paperBeige.opacity(0.3))
                            .overlay(
                                Image(systemName: "book.closed.fill")
                                    .foregroundColor(.brownLeather.opacity(0.7))
                                    .font(.title2)
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 100)
                    .clipShape(Rectangle())
                    .overlay(
                        Rectangle()
                            .stroke(Color.antiqueGold.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .brownLeather.opacity(0.2), radius: 6, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(story.bookId.title)
                        .font(.scoreDream(.bold, size: .subheadline))
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(story.bookId.author.joined(separator: ", "))
                        .font(.scoreDream(.medium, size: .caption))
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                    
                    Text(story.bookId.publisher)
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText.opacity(0.8))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.brownLeather.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
    }
    
    private var keywordSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(story.keywords ?? [], id: \.self) { keyword in
                    
                    Text("#\(keyword)")
                        .font(.scoreDream(.medium, size: .caption))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 30)
    }

    private var storyDateAndIsPublicSection: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: story.isPublic ? "eye.fill" : "eye.slash.fill")
                    .font(.caption)
                    .foregroundColor(story.isPublic ? .brownLeather : .secondaryText)
                
                Text(story.isPublic ? "공개" : "비공개")
                    .font(.scoreDream(.medium, size: .caption))
                    .foregroundColor(story.isPublic ? .brownLeather : .secondaryText)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(story.isPublic ? Color.brownLeather.opacity(0.1) : Color.secondaryText.opacity(0.1))
            )
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(.secondaryText.opacity(0.7))
                
                Text("작성일: \(story.updatedAt.prefix(10))")
                    .font(.scoreDream(.light, size: .caption))
                    .foregroundColor(.secondaryText.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var commentSheetToggleButton: some View {
        Button {
            detailViewModel.isCommentSheetExpanded = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.primaryText)

                VStack(alignment: .leading, spacing: 2) {
                    Text("댓글")
                        .font(.scoreDream(.medium, size: .callout))
                        .foregroundColor(.primaryText)
                    
                    Text("\(commentViewModel.totalCommentCount)")
                        .font(.scoreDream(.light, size: .caption))
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondaryText.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brownLeather.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
            .padding(.horizontal, 20)
        }
        .buttonStyle(CardButtonStyle())
    }
}
