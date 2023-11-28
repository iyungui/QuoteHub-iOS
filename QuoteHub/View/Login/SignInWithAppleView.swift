//
//  SignInWithAppleView.swift
//  QuoteHub
//
//  Created by 이융의 on 10/22/23.
//

import SwiftUI
import AuthenticationServices
import Alamofire

struct SignInWithAppleView: View {
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    @State private var shouldNavigateToMain = false
    
    var body: some View {
        VStack {
            SignInWithAppleButton(.signIn, onRequest: { request in
                request.requestedScopes = [.email]
            }, onCompletion: { result in
                switch result {
                case .success(let authResults):
                    guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                          let authorizationCode = appleIDCredential.authorizationCode,
                          let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return }
                    
                    self.handleAuthorization(appleIDCredential: appleIDCredential, authCodeString: authCodeString)
                    
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                }
            })
            NavigationLink(destination: MainView().environmentObject(userAuthManager), isActive: $shouldNavigateToMain) {
                EmptyView()
            }
        }
    }
    
    func handleAuthorization(appleIDCredential: ASAuthorizationAppleIDCredential, authCodeString: String) {
        let requestBody: [String: Any] = [
            "code": authCodeString
        ]
        let url = APIEndpoint.signInWithAppleURL

        AF.request(url, method: .post, parameters: requestBody, encoding: JSONEncoding.default).responseDecodable(of: SignInWithAppleResponse.self) { response in
            switch response.result {
            case .success(let signInResponse):
                KeyChain.create(key: "JWTAccessToken", token: signInResponse.JWTAccessToken)
                KeyChain.create(key: "JWTRefreshToken", token: signInResponse.JWTRefreshToken)
                
                self.userAuthManager.showingLoginView = false
                DispatchQueue.main.async {
                    self.userAuthManager.isUserAuthenticated = true
                    self.userAuthManager.isOnboardingComplete = false
                    self.shouldNavigateToMain = true
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}



