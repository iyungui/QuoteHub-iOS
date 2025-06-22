//
//  BookStoryToolbarItems.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct BookStoryToolbarItems: View {
    @Bindable var detailViewModel: BookStoryDetailViewModel
    let userAuthManager: UserAuthenticationManager
    
    var body: some View {
        HStack {
            Button {
                detailViewModel.toggleViewMode()
            } label: {
                Image(systemName: detailViewModel.isCarouselView ? "square.3.layers.3d.down.backward" : "list.bullet.below.rectangle")
                    .scaleEffect(x: 1, y: detailViewModel.isCarouselView ? 1 : -1)
            }
            
            if userAuthManager.isUserAuthenticated {
                Button {
                    detailViewModel.toggleCommentSheet()
                } label: {
                    Image(systemName: "bubble.right")
                }
                
                Button {
                    detailViewModel.showActionSheetView()
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
    }
}
