//
//  ProfileImage.swift
//  QuoteHub
//
//  Created by 이융의 on 6/17/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileImage: View {
    let profileImageURL: String
    let size: CGFloat
    
    var url: URL? {
        URL(string: profileImageURL)
    }
    
    var body: some View {
        VStack {
            WebImage(url: url)
                .placeholder {
                    Circle()
                        .fill(Color.paperBeige.opacity(0.5))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.brownLeather.opacity(0.7))
                                .font(.title2)
                        )
                }
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                .shadow(radius: 4)
        }
    }
}
