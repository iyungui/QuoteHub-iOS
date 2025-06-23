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
    @Environment(UserAuthenticationManager.self) private var userAuthManager
    
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
                    .font(ScoreDreamFont.font(.medium, size: .title1))
                    .fontWeight(.black)
                    .padding(.top)
                Spacer()
            }
            .padding(.leading, 50)
            
            HStack {
                AnimatedText(.constant(onboardingPages[index].description),
                             currentPage: $currentPage,
                             targetPage: index)
                .font(.scoreDreamBody)
                
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
                        .font(.scoreDream(.extraBold, size: .medium))
                        .foregroundColor(.white)
                        .frame(width: 280, height: 60, alignment: .center)
                        .background(Color.black)
                        .cornerRadius(8)
                        .padding(.bottom, 10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button(action: {
                currentPage = 3 // 마지막 페이지로 이동
            }) {
                Text("건너뛰기")
                    .font(.scoreDream(.regular, size: .callout))
                    .underline()
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
    .environment(UserAuthenticationManager())
}
