//
//  ListThemaView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/11/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ListThemaView: View {
    @ObservedObject var viewModel: FolderViewModel
    
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(Array(viewModel.folder.enumerated()), id: \.element.id) { index, folder in
                    FolderView(folder: folder, index: index)
                        .environmentObject(viewModel)
                        .environmentObject(myFolderViewModel)
                        .environmentObject(userViewModel)
                        .environmentObject(myStoriesViewModel)
                        .environmentObject(userAuthManager)
                }
                
                if !viewModel.isLastPage {
                    loadingIndicator()
                }
            }
            .frame(height: 200)
            .padding(.horizontal, 30)
        }
    }
    
    private func loadingIndicator() -> some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.brownLeather)
            
            Text("테마 더 불러오는 중...")
                .font(.scoreDream(.light, size: .caption))
                .foregroundColor(.secondaryText)
                .padding(.top, 8)
        }
        .frame(width: 120)
        .onAppear {
            viewModel.loadMoreIfNeeded(currentItem: viewModel.folder.last)
        }
    }
}

struct FolderView: View {
    let folder: Folder
    let index: Int
    
    @EnvironmentObject var viewModel: FolderViewModel
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    private var themeGradient: [Color] {
        let gradients: [[Color]] = [
            [.paperBeige, .brownLeather],
            [.antiqueGold, .paperBeige],
            [.brownLeather, Color.purple.opacity(0.7)],
            [Color.orange.opacity(0.8), Color.red.opacity(0.7)],
            [Color.teal.opacity(0.8), .antiqueGold],
            [.brownLeather, .antiqueGold]
        ]
        return gradients[index % gradients.count]
    }
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack {
                // 배경 이미지
                backgroundImage
                
                // 그라데이션 오버레이
                gradientOverlay
                
                // 컨텐츠
                contentView
            }
            .frame(width: 240, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 20))

        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var backgroundImage: some View {
        WebImage(url: URL(string: folder.folderImageURL))
            .placeholder {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: themeGradient),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 240, height: 180)
    }
    
    private var gradientOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.clear,
                Color.clear,
                themeGradient[0].opacity(0.7),
                themeGradient[1].opacity(0.8)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var contentView: some View {
        VStack {
            // 상단 아이콘과 사용자 정보
            HStack {
                Spacer()
                
                // 사용자 프로필
                userProfileView
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            Spacer()
            
            // 하단 텍스트 정보
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(folder.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                    
                    // 화살표 아이콘
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Text(folder.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                
                HStack {
                    Spacer()
                    
                    Text(folder.createdAtDate)
                        .font(.scoreDream(.light, size: .footnote))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 16)
        }
    }
    
    private var userProfileView: some View {
        HStack(spacing: 8) {
            // 프로필 이미지
            if let url = URL(string: folder.userId.profileImage), !folder.userId.profileImage.isEmpty {
                WebImage(url: url)
                    .placeholder {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 12))
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            } else {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 12))
                    )
            }
            
            Text(folder.userId.nickname)
                .font(.scoreDream(.medium, size: .footnote))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
    }
    
    private var destinationView: some View {
        if folder.userId.id == userViewModel.user?.id {
            return AnyView(ThemaView(folderId: folder.id)
                .environmentObject(myFolderViewModel)
                .environmentObject(userViewModel)
                .environmentObject(myStoriesViewModel)
            )
        } else {
            return AnyView(PublicThemaView(folder: folder)
                .environmentObject(viewModel)
                .environmentObject(userAuthManager))
        }
    }
}
