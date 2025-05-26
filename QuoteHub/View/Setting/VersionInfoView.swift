//
//  VersionInfoView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/10/02.
//

import SwiftUI

struct VersionInfoView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("문장 모아")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            Text("문장을 모아 지혜를 담다.")
                .font(.headline)
                .foregroundColor(.gray)

            Spacer().frame(height: 50)

            Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}
