//
//  OnboardingView.swift
//  QuoteHub
//
//  Created by 이융의 on 10/24/23.
//

import SwiftUI

struct OnboardingData {
    var image: String
    var title: String
    var description: String
}

let onboardingPages: [OnboardingData] = [
    OnboardingData(image: "preview_1", title: "기록하기", description: "책을 읽으며 간직하고 싶은\n나만의 문장을 기록해보세요."),
    OnboardingData(image: "preview_2", title: "키워드 설정", description: "키워드를 통해 나의 기록은 물론\n친구의 기록을 검색할 수 있어요."),
    OnboardingData(image: "preview_3", title: "테마 설정", description: "테마를 통해 나의 문장들을 분류하고\n한 눈에 모아볼 수 있어요.")
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
                        // 첫 4개 페이지
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
                                Text(onboardingPages[index].description)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.leading, 50)

//                            Image(onboardingPages[index].image)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 200, height: 200)
//                                .padding(10)
                            
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
                        .tag(index)
                    } else {
                        VStack(alignment: .center, spacing: 15) {
                            Spacer()

                            Text("지금 바로 나만의 문장을 기록해보세요.")
                                .font(.largeTitle)
                                .multilineTextAlignment(.center)
                                .fontWeight(.black)
                                .padding(.horizontal, 20)

                            Text("문장을 모아 지혜를 담다, 문장모아")
                                .fontWeight(.semibold)
                                .font(.headline)
                                .padding(.horizontal, 20)

                            Spacer()
                                .frame(height: 35)
                            
                            SignInWithAppleView()
                              .frame(width: 280, height: 60, alignment: .center)
                              .signInWithAppleButtonStyle(colorScheme == .light ? .black : .whiteOutline)
                              .environmentObject(userAuthManager)
                            
                            Button("나중에 하기") {
                                userAuthManager.isOnboardingComplete = true
                            }
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            
                            Spacer()
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
}


