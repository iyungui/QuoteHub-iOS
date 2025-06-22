//
//  MyThemeContentView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

// MARK: - MyThemeContentView

struct MyThemeContentView: View {
    let selectedView: Int
    @Bindable var themeBookStoriesViewModel: MyThemeBookStoriesViewModel
    
    var body: some View {
        Group {
            if selectedView == 0 {
                MyThemeGalleryGridView(themeBookStoriesViewModel: themeBookStoriesViewModel)
            } else {
                MyThemeGalleryListView(themeBookStoriesViewModel: themeBookStoriesViewModel)
            }
        }
    }
}

// MARK: - PublicThemeContentView


