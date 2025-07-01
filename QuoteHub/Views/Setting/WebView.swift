//
//  WebView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/30/23.
//

import SwiftUI
import SafariServices

struct WebView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

//Canvas 미리보기용
//struct WebView_Previews: PreviewProvider {
//    static var previews: some View {
//        WebView(urlToLoad: "https://www.naver.com")
//    }
//}
