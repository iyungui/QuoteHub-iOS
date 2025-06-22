//
//  BookStoryContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct BookStoryContentView: View {
    let story: BookStory
    @Bindable var detailViewModel: BookStoryDetailViewModel
    let isMyStory: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if detailViewModel.isCarouselView {
                    CarouselStoryQuotesDisplayView(story: story)
                } else {
                    ListStoryQuotesDisplayView(story: story)
                }
                spacer(height: 20)
                CommonStoryDisplayView(story: story, isMyStory: isMyStory)
            }
        }
    }
}
