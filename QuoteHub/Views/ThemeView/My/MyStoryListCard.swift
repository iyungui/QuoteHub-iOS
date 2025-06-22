//
//  MyStoryListCard.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct MyStoryListCard: View {
    let story: BookStory
    @Environment(UserViewModel.self) private var userViewModel
    
    var body: some View {
        NavigationLink(destination: MyBookStoryDetailView(story: story)) {
            StoryListCardContent(story: story)
        }
        .buttonStyle(CardButtonStyle())
    }
}
