//
//  PublicThemeContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct PublicThemeContentView: View {
    let selectedView: Int
    @Bindable var themeBookStoriesViewModel: PublicThemeBookStoriesViewModel
    
    var body: some View {
        Group {
            if selectedView == 0 {
                PublicThemeGalleryGridView(themeBookStoriesViewModel: themeBookStoriesViewModel)
            } else {
                PublicThemeGalleryListView(themeBookStoriesViewModel: themeBookStoriesViewModel)
            }
        }
    }
}
