//
//  MyThemeNavigationItems.swift
//  QuoteHub
//
//  Created by 이융의 on 6/22/25.
//

import SwiftUI

struct MyThemeNavigationItems: View {
    @Binding var showActionSheet: Bool
    
    var body: some View {
        Button(action: {
            showActionSheet = true
        }) {
            Image(systemName: "ellipsis")
        }
    }
}
