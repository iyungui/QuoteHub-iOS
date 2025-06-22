//
//  LibraryNavigationItems.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct MyLibraryNavigationItems: View {
    var body: some View {
        HStack(spacing: 15) {
            ThemeToggleButton()
            
            NavigationLink(destination: SettingView()) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.brownLeather)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
}

struct FriendLibraryNavigationItems: View {
    @Binding var showActionSheet: Bool
    
    var body: some View {
        Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis")
                .foregroundColor(.brownLeather)
                .font(.system(size: 16, weight: .medium))
        }
    }
}
