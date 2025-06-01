//
//  FollowersListView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/16/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct FollowersListView: View {
    let userId: String?
    @EnvironmentObject private var followViewModel: FollowViewModel
    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
    
    @EnvironmentObject private var storiesViewModel: BookStoriesViewModel
    @EnvironmentObject private var themesViewModel: ThemesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel

    
    var body: some View {
        List {
            ForEach(followViewModel.followers) { friend in
                NavigationLink(destination: LibraryView(user: friend)
                    .environmentObject(userAuthManager)
                    .environmentObject(userViewModel)
                    .environmentObject(storiesViewModel)
                    .environmentObject(themesViewModel)
                ) {
                    HStack {
                        if let url = URL(string: friend.profileImage), !friend.profileImage.isEmpty {
                            WebImage(url: URL(string: friend.profileImage))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                                .padding(.trailing, 5)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .padding(.trailing, 5)
                        }
                        
                        VStack(alignment: .leading) {
                            if !friend.nickname.isEmpty {
                                Text(friend.nickname)
                                    .font(.headline)
                            } else {
                                Text("닉네임")
                                    .font(.headline)
                            }
                            
                            
                            Text(friend.statusMessage ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                }
            }
            if !followViewModel.isLastPage {
                ProgressView()
                    .onAppear {
                        followViewModel.FollowersloadMoreIfNeeded(currentItem: followViewModel.followers.last)
                    }
            }
        }
        .navigationTitle("친구 목록")
        .onAppear {
            followViewModel.resetLoadingState()
            followViewModel.loadFollowers(userId: userId ?? "")
        }
    }
}
