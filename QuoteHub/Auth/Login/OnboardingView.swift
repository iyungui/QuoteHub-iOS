//
//  OnboardingView.swift
//  QuoteHub
//
//  Created by 이융의 on 10/24/23.
//

import SwiftUI

struct OnboardingData {
    var title: String
    var description: String
}

let onboardingPages: [OnboardingData] = [
    OnboardingData(title: "기록하기", description: "책을 읽으며 간직하고 싶은\n나만의 문장을 기록해보세요."),
    OnboardingData(title: "키워드 설정", description: "키워드를 통해 나의 기록은 물론\n친구의 기록을 검색할 수 있어요."),
    OnboardingData(title: "테마 설정", description: "테마를 통해 나의 문장들을 분류하고\n한 눈에 모아볼 수 있어요.")
]

struct OnboardingView: View {
    @State private var currentPage = 0
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userAuthManager: UserAuthenticationManager

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<4, id: \.self) { index in
                    if index < 3 {
                        OnboardingContentView(currentPage: $currentPage, index: index)
                        .tag(index)
                    } else {
                        LoginView(isOnboarding: true)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}

struct OnboardingContentView: View {
    @Binding var currentPage: Int
    let index: Int
    var body: some View {
        
        VStack(alignment: .center, spacing: 15) {
            Spacer()
            
            HStack {
                Text(onboardingPages[index].title)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .padding(.top)
                Spacer()
            }
            .padding(.leading, 50)
            
            HStack {
                AnimatedText(.constant(onboardingPages[index].description),
                             currentPage: $currentPage,
                             targetPage: index)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.leading, 50)
            
            Spacer()
            
            if currentPage < 3 {
                Button(action: {
                    withAnimation {
                        currentPage += 1
                    }
                }) {
                    Text("다음")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 280, height: 60, alignment: .center)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button(action: {
                currentPage = 3 // 마지막 페이지로 이동
            }) {
                Text("건너뛰기")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }

}

#Preview {
    Group {
        OnboardingView()
    }
    .environmentObject(UserAuthenticationManager())
}

struct AnimatedText: View {
    
    // MARK: - Inits
    
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
    @Binding private var currentPage: Int
    private let targetPage: Int
    @State private var attributedText: AttributedString
    @State private var currentWorkItem: DispatchWorkItem?
    
    // MARK: - Properties ( View )
    
    var body: some View {
        Text(attributedText)
            .onAppear {
//                print("onAppear - page: \(targetPage), current: \(currentPage)")
                if currentPage == targetPage {
                    animateText()
                }
            }
            .onChange(of: currentPage) { _, newPage in
//                print("onChange - page: \(targetPage), newPage: \(newPage)")
                if newPage == targetPage {
                    animateText()  // 현재 페이지가 되면 시작
                } else {
                    cancelAnimation()  // 다른 페이지면 취소
                }
            }
            .onDisappear {
                print("onDisappear - page: \(targetPage)")
                cancelAnimation()
            }
    }
    
    // MARK: - Methods ( Private )

    private func cancelAnimation() {
//        print("cancelAnimation - page: \(targetPage)")
        var initialAttributedText = AttributedString(text)
        initialAttributedText.foregroundColor = .clear
        attributedText = initialAttributedText

        currentWorkItem?.cancel()
        currentWorkItem = nil
    }
    
    private func animateText(at position: Int = 0) {
//        print("animateText - page: \(targetPage), position: \(position)/\(text.count)")
        
        guard position <= text.count else {
            attributedText = AttributedString(text)
//            print("애니메이션 완료 - page: \(targetPage)")
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
