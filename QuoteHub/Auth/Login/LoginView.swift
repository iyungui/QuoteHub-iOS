//
//  LoginView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    let isOnboarding: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            if !isOnboarding {
                HStack {
                    Button {
                        userAuthManager.showingLoginView = false
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            Spacer()
            
            Text("지금 바로 나만의 문장을 기록해보세요.")
                .font(.scoreDreamTitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Text("문장을 모아 지혜를 담다, 문장모아")
                .font(.scoreDream(.medium, size: .body))
                .padding(.horizontal, 20)

            Spacer()
                .frame(height: 35)

            SignInWithAppleView()
              .frame(width: 280, height: 60, alignment: .center)
              .signInWithAppleButtonStyle(colorScheme == .light ? .black : .whiteOutline)
              .environmentObject(userAuthManager)
            
            if isOnboarding {
                Button {
                    userAuthManager.isOnboardingComplete = true
                } label: {
                    Text("나중에 하기")
                        .font(.scoreDream(.regular, size: .callout))
                        .underline()
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .navigationBarBackButtonHidden(!isOnboarding)
    }
}

#Preview {
    LoginView(isOnboarding: true).environmentObject(UserAuthenticationManager())
}
