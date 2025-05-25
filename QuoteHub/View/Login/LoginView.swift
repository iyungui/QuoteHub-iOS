//
//  LoginView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/5/23.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Spacer()
            
            Text("지금 바로 나만의 문장을 기록해보세요.")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .fontWeight(.black)
                .padding(.horizontal, 20)
            
            Text("문장을 모아 지혜를 담다, 문장모아")
                .fontWeight(.semibold)
                .padding(.horizontal, 20)

            Spacer()
                .frame(height: 35)

            SignInWithAppleView()
              .frame(width: 280, height: 60, alignment: .center)
              .signInWithAppleButtonStyle(colorScheme == .light ? .black : .whiteOutline)
              .environmentObject(userAuthManager)
            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
}
