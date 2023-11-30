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
            LazyHStack(spacing: 15) {
                ForEach(viewModel.folder, id: \.id) { folder in
                    FolderView(folder: folder)
                        .environmentObject(viewModel)
                        .environmentObject(myFolderViewModel)
                        .environmentObject(userViewModel)
                        .environmentObject(myStoriesViewModel)
                        .environmentObject(userAuthManager)
                }
                if !viewModel.isLastPage {
                    ProgressView()
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentItem: viewModel.folder.last)
                        }
                }
            }
            .frame(height: 150)
            .padding(.horizontal, 30)
        }
    }
}

struct FolderView: View {
    let folder: Folder
    @EnvironmentObject var viewModel: FolderViewModel
    
    @EnvironmentObject var myFolderViewModel: MyFolderViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var myStoriesViewModel: BookStoriesViewModel
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    var body: some View {
        NavigationLink(destination: destinationView) {
            ZStack(alignment: .bottomLeading) {
                WebImage(url: URL(string: folder.folderImageURL))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 150)
                    .cornerRadius(4)
                    .clipped()
                    .overlay(Rectangle().stroke(Color.gray.opacity(0.5), lineWidth: 1))

                
                // 텍스트 배경 효과
                Text(folder.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(4)
                    .padding([.leading, .bottom], 10)
            }
            .frame(width: 200, height: 150)
            .clipped()
            .shadow(radius: 1)
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
            return AnyView(PublicThemaView(folder: folder).environmentObject(viewModel).environmentObject(userAuthManager))
        }
    }
}


