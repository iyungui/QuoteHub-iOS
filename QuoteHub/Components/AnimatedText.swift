//
//  AnimatedText.swift
//  QuoteHub
//
//  Created by 이융의 on 5/31/25.
//

import SwiftUI

struct AnimatedText: View {
    
    // MARK: - Inits
    
    init(_ text: Binding<String>) {
        self._text = text
        self._currentPage = nil
        self.targetPage = nil
        var attributedText = AttributedString(text.wrappedValue)
        attributedText.foregroundColor = .clear
        self._attributedText = State(initialValue: attributedText)
    }
    
    init(_ text: Binding<String>, currentPage: Binding<Int>, targetPage: Int) {
        self._text = text
        self._currentPage = currentPage
        self.targetPage = targetPage
        var attributedText = AttributedString(text.wrappedValue)
        attributedText.foregroundColor = .clear
        self._attributedText = State(initialValue: attributedText)
    }

    // MARK: - Properties ( Private )
    
    @Binding private var text: String
    private var _currentPage: Binding<Int>?
    private let targetPage: Int?
    @State private var attributedText: AttributedString
    @State private var currentWorkItem: DispatchWorkItem?
    
    private var currentPage: Int { _currentPage?.wrappedValue ?? 0 }
    private var flag: Bool { _currentPage != nil && targetPage != nil }  // 탭뷰에서는 true
    
    // MARK: - Properties ( View )
    
    var body: some View {
        Text(attributedText)
            .onAppear {
                if flag && currentPage == targetPage { animateText() } else { animateText() }
            }
            .onChange(of: _currentPage?.wrappedValue ?? 0) { _, newPage in
                if flag {
                    if newPage == targetPage {
                        animateText()  // 현재 페이지가 되면 시작
                    } else {
                        cancelAnimation()  // 다른 페이지면 취소
                    }
                }
            }
            .onDisappear {
                cancelAnimation()
            }
    }
    
    // MARK: - Methods ( Private )

    private func cancelAnimation() {
        var initialAttributedText = AttributedString(text)
        initialAttributedText.foregroundColor = .clear
        attributedText = initialAttributedText

        currentWorkItem?.cancel()
        currentWorkItem = nil
    }
    
    private func animateText(at position: Int = 0) {
        guard position <= text.count else {
            attributedText = AttributedString(text)
            return
        }
        
        let workItem = DispatchWorkItem {
            let stringStart = String(text.prefix(position))
            let stringEnd = String(text.suffix(text.count - position))
            let attributedTextStart = AttributedString(stringStart)
            var attributedTextEnd = AttributedString(stringEnd)
            attributedTextEnd.foregroundColor = .clear
            self.attributedText = attributedTextStart + attributedTextEnd
            self.animateText(at: position + 1)
        }
        
        currentWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
}
