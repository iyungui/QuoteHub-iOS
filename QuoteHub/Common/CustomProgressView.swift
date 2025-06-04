//
//  CustomProgressView.swift
//  QuoteHub
//
//  Created by 이융의 on 6/4/25.
//

import SwiftUI
import Lottie

struct CustomProgressView: View {
    let animationName: String
    let message: String?
    let size: CGSize
    let loopMode: LottieLoopMode
    
    init(
        animationName: String,
        message: String? = nil,
        size: CGSize = CGSize(width: 100, height: 100),
        loopMode: LottieLoopMode = .loop
    ) {
        self.animationName = animationName
        self.message = message
        self.size = size
        self.loopMode = loopMode
    }
    
    var body: some View {
        VStack(spacing: 16) {
            LottieView(animation: .named(animationName))
                .playing(loopMode: loopMode)
                .resizable()
                .scaledToFit()
                .frame(width: size.width, height: size.height)

            
            if let message = message {
                Text(message)
                    .font(.scoreDream(.medium, size: .subheadline))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Protocol

protocol LoadingViewModel: ObservableObject {
    var isLoading: Bool { get }
    var loadingMessage: String? { get }
}

struct ProgressOverlay<VM: LoadingViewModel>: ViewModifier {
    @ObservedObject var viewModel: VM
    let animationName: String
    
    func body(content: Content) -> some View {
        content
            // 화면 전체로 확장
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ZStack {
                            // 화면 전체를 덮는 반투명 배경
                            Color.black.opacity(0.3)
                                .ignoresSafeArea(.all)
                            
                            // Progress View
                            CustomProgressView(
                                animationName: animationName,
                                message: viewModel.loadingMessage,
                                size: CGSize(width: 100, height: 100)
                            )
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                    }
                }
            )
    }
}

// MARK: - View Extension

extension View {
    func progressOverlay<VM: LoadingViewModel>(
        viewModel: VM,
        animationName: String = "progressLottie"
    ) -> some View {
        self.modifier(ProgressOverlay(viewModel: viewModel, animationName: animationName))
    }
}


/*
/// MARK: - 사용 방법

class LoginTestViewModel: ObservableObject, LoadingViewModel {
    @Published var isLoading = false
    @Published var loadingMessage: String?
    @Published var user: String?
    
    func login() {
        isLoading = true
        loadingMessage = "login..."
        
        // 네트워크 요청 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.loadingMessage = nil
            self.user = "융의"
        }
    }
}

struct LoadingExampleView: View {
    @StateObject private var vm = LoginTestViewModel()
    var body: some View {
        VStack(spacing: 20) {
            Text("Login View").font(.title)
            
            Button("로그인하기") { vm.login() }
                .buttonStyle(.borderedProminent)
            
            if let user = vm.user {
                Text("환영합니다, \(user)님")
                    .foregroundStyle(.green)
            }
        }
        .progressOverlay(viewModel: vm)
    }
}
*/
