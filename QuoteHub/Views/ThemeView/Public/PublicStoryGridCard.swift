//
//  PublicStoryGridCard.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct PublicStoryGridCard: View {
    let story: BookStory
    @Environment(UserViewModel.self) private var userViewModel
    
    var body: some View {
        NavigationLink(destination: PublicBookStoryDetailView(story: story)) {
            StoryGridCardContent(story: story)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
